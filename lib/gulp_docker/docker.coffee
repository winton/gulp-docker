fs           = require "fs"
DockerRemote = require "docker-remote"
Promise      = require "bluebird"

module.exports = (GulpDocker) -> 

  # Entry point for building Docker images and running containers.
  #
  class GulpDocker.Docker

    # Initializes `@containers`.
    #
    # @param [Object] container configuration object
    #
    constructor: (@containers) ->
      @ask       = GulpDocker.ask
      @image_api = new DockerRemote.Api.Image()

      for name, container of @containers
        container.name = name

    # Helper method to list the containers and then ask questions.
    #
    # @param [String] question_type "images to build" or "containers
    #   to run"
    # @return [Promise<Array>] promise that returns an array of
    #   containers
    #
    askForContainers: (question_type) ->
      [ containers, questions ] = @containerStrings()

      questions.push("\nEnter number(s) of #{question_type} (enter for all):")

      @ask(questions.join("\n"), /(\d|\s*)/).then(
        (input) -> 
          if input == ""
            containers
          else
            input.match(/\d/g).map (index) ->
              containers[parseInt(index) - 1]
      )

    # Helper method to ask if the user wants to push images to
    # their Docker registry.
    #
    # @param [Array] containers an array of container objects
    # @return [Promise<Array>]promise that returns an array of
    #   containers
    #
    askForPush: (containers) ->
      @ask("Push to docker registry?", /[yYnN]/).then(
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
        (containers) => @askForPush(containers)
      ).each(
        (container) => new DockerRemote.Image(container).build()
      )

    # Asks which Docker containers to restart and restarts them.
    #
    restart: ->
      @stop().then(=> @run())

    # Asks which Docker containers to run and runs them.
    #
    run: ->
      containers = null

      @askForContainers("containers to run").then(
        (conts) -> containers = conts
      ).each(
        (container) =>
          new DockerRemote.Image(container).create()
      ).then(
        -> containers
      ).each(
        (container) =>
          new DockerRemote.Container(container).run()
      )

    # Asks which Docker containers to stop and stops them.
    #
    stop: ->
      @askForContainers("containers to stop").each(
        (container) => new DockerRemote.Container(container).rm()
      )
