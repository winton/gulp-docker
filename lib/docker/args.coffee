module.exports = (Docker) -> 

  # Generates arguments for Docker CLI and remote API.
  #
  class Docker.Args

    # Initializes `@container`.
    #
    # @param [Object] @container container object
    #
    constructor: (@container) ->
      console.log @container

    # Generates parameters for a Docker remote API call.
    #
    # @return [Object]
    #
    apiParams: ->
      name:  @container.name
      Cmd:   @container.command
      Image: "#{@container.repo}:latest"
      Env:   @envs()
      HostConfig:
        Binds: @binds()
        PortBindings: @portBindings()
      ExposedPorts: @exposedPorts()

    # Generate binds option (which local directories to mount
    # within the container).
    #
    # @return [Object]
    #
    binds: ->
      binds = []
      env   = @container.env

      binds.push(
        "#{env.APP_PATH || process.cwd()}:/app"
      ) if !env.ENV || env.ENV == "development"
      binds.push(
        "#{env.DOCKER_CERT_PATH}:/certs/docker"
      ) if env.DOCKER_CERT_PATH
      binds.push(
        "#{env.DOCKER_SOCKET_PATH}:/var/run/host"
      ) if env.DOCKER_SOCKET_PATH

      binds

    # Generates parameters for a Docker CLI call.
    #
    # @return [Object]
    #
    cliParams: (options={}) ->
      params = [ "--name", @name ]

      for env in @envs()
        params.push("-e")
        params.push(env)

      for bind in @binds()
        params.push("-v")
        params.push(bind)

      for client_port, host_ports of @portBindings()
        for host_port in host_ports
          params.push("-p")
          params.push(
            "#{host_port.HostPort}:#{client_port.split("/")[0]}"
          )

      params.push(Docker.repoName(@name))
      params.concat(@command)

    # Generate environment variables to be passed to the container.
    #
    # @return [Array<String>] an array of strings in "VAR=var" format
    #
    envs: ->
      envs = []

      for key, value of @container.env
        envs.push("#{key}=#{value}")

      envs

    # Generate an object for the `ExposedPorts` option of the Docker
    # API.
    #
    # @return [Object]
    #
    exposedPorts: ->
      ports = @portBindings(@name)
      ports[key] = {} for key, value of ports
      ports

    # Generate an object for the `PortBindings` option of the
    # Docker API.
    #
    # @return [Object]
    #
    portBindings: ->
      ports = {}
      for port in @container.ports
        [ host_port, container_port ]  = port
        ports["#{container_port}/tcp"] = [ HostPort: host_port ]
      ports
