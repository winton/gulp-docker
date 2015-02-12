fs      = require "fs"
Promise = require "bluebird"
ask     = require "./ask"
spawn   = require("./spawn")()

# Entry point for building Docker images and running containers.
#
class Docker

  # Initializes `@containers`.
  #
  # @param [Object] container configuration object
  #
  constructor: (@containers) ->
    for name, container of @containers
      container.name = name

  # Helper method to list the containers and then ask questions.
  #
  # @param [String] question_type "images to build" or "containers
  # to run"
  # @return [Promise<Array>] promise that returns an array of
  # containers
  #
  askForContainers: (question_type) ->
    [ containers, questions ] = @containerStrings()

    questions.push("\nPlease enter number(s) of #{question_type}:")

    ask(questions.join("\n"), /\d/).then(
      (input) -> input.match(/\d/g)
    ).map(
      (index) -> containers[parseInt(index) - 1]
    )

  # Helper method to ask if the user wants to push images to
  # their Docker registry.
  #
  # @param [Array] containers an array of container objects
  # @return [Promise<Array>]promise that returns an array of
  # containers
  #
  askForPush: (containers) ->
    ask("Push to docker registry?", /[yYnN]/).then(
      (output) ->
        console.log ""
        for container in containers
          container.push = output.match(/[yY]/)
        containers
    )

  # Turns `@containers` into an array of objects and strings for
  # questioning.
  #
  # @return [Array<Array,Array>] containers and questions
  #
  containerStrings: ->
    index      = 0
    containers = []
    questions  = []
    
    for name, container of @containers
      index++
      containers.push container
      questions.push "(#{index}) #{name}"

    [ containers, questions ]

  # Asks which Docker images to build and builds them.
  #
  image: ->
    @askForContainers("images to build").then(
      (containers) =>
        @askForPush(containers)
    ).map(
      (container) =>
        @modifyContainer(container)
    ).each(
      (container) =>
        new Docker.Image(container).build()
    )

  # Changes the container object to make consumption by subclasses
  # easier.
  #
  # @param [String] name container name
  # @param [Object] container container object
  # @return [Object] container container object
  #
  modifyContainer: (container) ->
    [ container.git, container.branch ] = container.git.split("#")

    container.branch ||= "master"
    container.ports  ||= []
    
    spawn("docker images").then(
      (output) =>
        container.has_image = !!output.match(
          ///#{container.repo}\s+latest///g
        )
        container
    )


  # Asks which Docker containers to run and runs them.
  #
  run: ->
    @askForContainers("containers to run").map(
      (container) =>
        @modifyContainer(container)
    ).then(
      (containers) =>
        missing_images = containers.filter(
          (item) -> !item.has_image
        )
        if missing_images.length
          @askForPush(containers)
        else
          containers
    ).each(
      (container) =>
        new Docker.Container(container).run()
    )

require("./docker/api")(Docker)
require("./docker/args")(Docker)
require("./docker/container")(Docker)
require("./docker/image")(Docker)

module.exports = Docker