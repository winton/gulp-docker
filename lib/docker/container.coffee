module.exports = (Docker) -> 

  # List, run, and remove Docker containers.
  #
  class Docker.Container

    # Instantiate a `Docker.Api.Container` instance.
    #
    # @param [Object] @container container configuration object
    #
    constructor: (@container) ->
      @container = new Docker.Api.Container(@container)

    # List Docker containers.
    #
    # @param [Object] options parameter to `Docker.Api.Container#list`
    # @return [Array<Object>]
    #
    ps: (options) ->
      @container.list(options)

    # Run a Docker container.
    #
    # @param [Object] options parameter to `Docker.Args`
    # @return [Promise<Object>]
    #
    run: (options) ->
      args = new Docker.Args(@container)

      @rm().then(=>
        @container.create(
          args.apiParams()
        )
      ).then =>
        @container.start()

    # Remove a Docker container.
    #
    # @param [Object] options parameter to `Docker.Api.Container#remove`
    #
    rm: (options={}) ->
      if options.force == undefined
        options.force = true

      @container.remove(options)