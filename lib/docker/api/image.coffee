fs      = require("fs")
Promise = require("bluebird")

module.exports = (Docker) ->

  # List Docker images.
  #
  class Docker.Api.Image

    # Initialize `Docker.Api.Client` and a `Dockerode`
    # container instance.
    #
    constructor: (@container) ->
      @client = new Docker.Api.Client()

    # Download and create a Docker image.
    #
    # @return [Promise<Array>]
    #
    create: ->
      @client.createImage(
        fromImage: @container.repo
        tag: "latest"
      )

    # List Docker images.
    #
    # @param [Object] params parameters to the image list API
    #   call
    #
    list: (params) ->
      @client.listImages(params)
