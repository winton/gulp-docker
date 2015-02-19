Promise = require("bluebird")

module.exports = (Docker) ->

  # List Docker images.
  #
  class Docker.Api.Image

    # Initialize `Docker.Api.Client` and a `Dockerode`
    # container instance.
    #
    constructor: ->
      @client = new Docker.Api.Client()

    list: (params) ->
      @client.listImages(params)