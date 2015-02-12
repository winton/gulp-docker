Promise = require("bluebird")

module.exports = (Docker) ->

  # Create, find, list, remove, and start Docker containers.
  #
  class Docker.Api.Container

    # Initialize `Docker.Api.Client` and a `Dockerode`
    # container instance.
    #
    constructor: (@container) ->
      @client = new Docker.Api.Client()

      @api_container = @find((container) =>
        container.Names.indexOf("/#{@container.name}") > -1
      ).then (container) =>
        @client.getContainer(container.Id) if container

    # Create a Docker container.
    #
    # @param [Object] params parameters to `Docker.Api.Client#createContainer`
    # @return [Promise<Container>]
    #
    create: (params) ->
      @api_container = Promise.resolve(
        @client.createContainer(params)
      )

    # Find a Docker container.
    # 
    # @param [Function] fn callback
    # @return [Promise<Container>]
    #
    find: (fn) ->
      @client.listContainers(all: 1).then (containers) ->
        for container in containers
          return container if fn(container)
        null

    # List all Docker containers.
    #
    # @param [Object] params parameters to `Docker.Api.Client#listContainers`
    # @return [Array<Object>]
    #
    list: (options) -> @client.listContainers(options)

    # Remove a Docker container.
    # 
    # @param [Object] options parameters to `Dockerode::Container#remove`
    # @return [Object] response from `Dockerode::Container#remove`
    #
    remove: (options) ->
      @api_container.then (container) ->
        if container
          Promise.promisify(container.remove, container)(options)

    # Start a Docker container.
    #
    # @param [Container] container a `Dockerode::Container` object
    # @return [Object] response from `Dockerode::Container#start`
    #
    start: ->
      @api_container.then (container) ->
        if container
          Promise.promisify(container.start, container)()