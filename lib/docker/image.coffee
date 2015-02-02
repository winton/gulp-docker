spawn = require "../spawn"

module.exports = (Docker) -> 

  # Builds image from Dockerfile.
  #
  class Docker.Image

    # Initializes image name and commands.
    #
    # @param [String] @name
    #
    constructor: (@name) ->
      @commands =
        rmi:   "docker rmi #{@name}"
        build: "docker build -t #{@name} ."

    # Removes image and rebuilds it.
    #
    # @return [Promise<String,Number>] the output and exit code
    #
    build: ->
      spawn(@commands.rmi).then ->
        spawn(@commands.build, stdio: "inherit")