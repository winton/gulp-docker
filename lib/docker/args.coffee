module.exports = (Docker) -> 

  # Generates arguments for Docker CLI and remote API.
  #
  class Docker.Args

    # Initializes a container name, command to run, env variables,
    # and ports.
    #
    # @param [String] @name name of Docker container
    # @param [Object] @container `command`, `container`, `env`, `ports`
    #
    constructor: (@container={}) ->
      @command   = @container.command   || "bin/#{@name}"
      @container = @container.container || "#{Docker.repoName(@name)}-#{@name}"
      @env       = @container.env       || process.env
      @ports     = @container.ports     || []

    # Generates parameters for a Docker remote API call.
    #
    # @return [Object]
    #
    apiParams: ->
      name:  @container
      Cmd:   @command
      Image: Docker.repoName(@name)
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
      binds.push(
        "#{@env.APP_PATH || process.cwd()}:/app"
      ) if !@env.ENV || @env.ENV == "development"
      binds.push(
        "#{@env.DOCKER_CERT_PATH}:/certs/docker"
      ) if @env.DOCKER_CERT_PATH
      binds.push(
        "#{@env.DOCKER_SOCKET_PATH}:/var/run/host"
      ) if @env.DOCKER_SOCKET_PATH

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
      envs.push(
        "DOCKER_HOST=#{@env.DOCKER_HOST}"
      ) if @env.DOCKER_HOST && @env.ENV != "production"
      envs.push(
        "DOCKER_CERT_PATH=/certs/docker"
      ) if @env.DOCKER_CERT_PATH && @env.ENV != "production"
      envs.push(
        "DOCKER_SOCKET_PATH=/var/run/host"
      ) if @env.DOCKER_SOCKET_PATH || @env.ENV == "production"
      envs.push(
        "ENV=#{@env.ENV}"
      ) if @env.ENV
      envs.push(
        "AWS_ACCESS_KEY_ID=#{@env.AWS_ACCESS_KEY_ID}"
      ) if @env.AWS_ACCESS_KEY_ID
      envs.push(
        "AWS_SECRET_ACCESS_KEY=#{@env.AWS_SECRET_ACCESS_KEY}"
      ) if @env.AWS_SECRET_ACCESS_KEY
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
      for port in @ports
        [ host_port, container_port ] = port
        ports["#{container_port}/tcp"] = [ HostPort: host_port ]
      ports
