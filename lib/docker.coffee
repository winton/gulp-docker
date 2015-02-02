fs  = require "fs"
ask = require "./ask"

# Entry point for building Docker images and running containers.
#
class Docker

  # Initializes `@containers`.
  #
  # @param [Object] container configuration object
  #
  constructor: (@containers) ->

  # Helper method to list the containers and then ask a question.
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

  # Turns `@containers` into an array of objects and strings for
  # questioning.
  #
  # @return [Array<Array,Array>] containers and questions
  #
  containerStrings: ->
    index      = 0
    containers = []
    questions  = [ "" ]
    
    for name, container of @containers
      index++
      containers.push container
      questions.push "(#{index}) #{name}"

    [ containers, questions ]

  # Asks which Docker images to build and builds them.
  #
  image: ->
    @askForContainers("images to build").then(
      (containers) ->
        console.log(containers)
    )

  # Asks which Docker containers to run and runs them.
  #
  run: ->
    @askForContainers("containers to run").then(
      (containers) ->
        console.log(containers)
    )

require("./docker/api")(Docker)
require("./docker/args")(Docker)
require("./docker/container")(Docker)
require("./docker/image")(Docker)

module.exports = Docker