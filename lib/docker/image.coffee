Promise  = require "bluebird"
spawn    = require("../spawn")("inherit")
spawnOut = require("../spawn")()

module.exports = (Docker) -> 

  # Builds image from Dockerfile.
  #
  class Docker.Image

    # Initializes image commands and command spawner.
    #
    # @param [Object] @container container object
    #
    constructor: (@container) ->
      @commands =
        clone:
          """
          git clone -b #{@container.branch} \
            --single-branch #{@container.git} \
            tmp/#{@container.name}
          """
        mkdir: "mkdir -p tmp/#{@container.name}"
        rmrf:  "rm -rf tmp/#{@container.name}"
        rmi:   "docker rmi #{@container.name}"
        sha:   "git rev-parse HEAD"

    # Builds an image.
    #
    # @return [Promise<String,Number>] the output and exit code
    #
    build: ->
      spawnOut(@commands.rmrf).then(=>
        spawnOut(@commands.mkdir)
      ).then(=>
        spawn(@commands.clone)
      ).then(=>
        spawnOut(@commands.sha)
      ).then(
        (sha) =>
          sha = sha.substring(0,8)
          Promise.props(
            build: spawn(@buildCommand(sha))
            sha:   sha
          )
      ).then(
        (props) =>
          props.tag = spawn(@tagCommand(props.sha))
          Promise.props(props)
      ).then(
        (props) =>
          if @container.push
            spawn(@pushCommand(props.sha))
      )

    # Generates the docker build command.
    #
    # @param [String] sha the git sha hash of the project
    # @return [String] the docker build command
    #
    buildCommand: (sha) ->
      """
      docker build \
        -t #{@container.repo}:#{sha} \
        tmp/#{@container.name}
      """

    # Generates the docker push command.
    #
    # @param [String] sha the git sha hash of the project
    # @return [String] the docker push command
    #
    pushCommand: (sha) ->
      "docker push #{@container.repo}:#{sha}"

    # Generates the docker tag command.
    #
    # @param [String] sha the git sha hash of the project
    # @return [String] the docker tag command
    #
    tagCommand: (sha) ->
      """
      docker tag \
        #{@container.repo}:#{sha} \
        #{@container.repo}:latest
      """