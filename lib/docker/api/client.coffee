fs        = require("fs")
Dockerode = require("dockerode")
Promise   = require("bluebird")

module.exports = (Docker) ->

  # Wrapper for `Dockerode`.
  #
  # @see https://github.com/apocas/dockerode
  #
  class Docker.Api.Client

    # Find the appropriate means to connect to Docker and
    # initialize the `Dockerode` client.
    #
    constructor: ->
      [ host, port ] = @hostAndPort()

      @client   = @fromCert(host, port)
      @client ||= @fromSocket()
      @client ||= @fromHostAndPort(host, port)

      Promise.promisifyAll(@client)

    # Generates a Docker API authConfig object.
    #
    # @param [String] Docker repository
    # @return [Object] Docker authConfig object
    #
    authObject: (repo) ->
      [ registry, repo, image ] = repo.split("/")

      cfg = @dockerCfg()[registry]

      auth = new Buffer(cfg.auth, "base64")
      [ username, password ] = auth.toString().split(":")

      username: username
      password: password
      email: cfg.email
      serveraddress: registry

    # Create a Docker container.
    #
    # @param [Object] params parameters to `Dockerode#createContainer`
    # @return [Container]
    #
    createContainer: (params) ->
      @client.createContainerAsync(params)

    # Create a Docker image.
    #
    # @param [Object] params parameters to `Dockerode#createImage`
    # @return [Container]
    #
    createImage: (params) ->
      response = []
      new Promise (resolve) =>
        @client.createImage(
          @authObject(params.fromImage)
          params
          (error, output) ->
            output.on(
              "data"
              (buf) ->
                response.push JSON.parse(buf.toString())
            )
            output.on("end", -> resolve(output))
        )

    # Read the .dockercfg from the home directory and parse it.
    #
    # @return [Object]
    #
    dockerCfg: ->
      cfg_dir = process.env.DOCKER_CONFIG_DIR || process.env.HOME
      cfg     = fs.readFileSync("#{cfg_dir}/.dockercfg").toString()

      JSON.parse(cfg)

    # Connect to Docker using a certificate if `DOCKER_CERT_PATH`
    # env variable present.
    #
    # @param [String] host the hostname of the Docker remote API
    # @param [Number] port the port of the Docker remote API
    # @return [Dockerode]
    #
    fromCert: (host, port) ->
      cert_path = process.env.DOCKER_CERT_PATH

      return undefined unless cert_path

      new Dockerode(
        host:     host
        port:     port
        protocol: 'https'
        ca:       fs.readFileSync("#{cert_path}/ca.pem")
        cert:     fs.readFileSync("#{cert_path}/cert.pem")
        key:      fs.readFileSync("#{cert_path}/key.pem")
      )

    # Connect to Docker over http with a host and port.
    #
    # @param [String] host the hostname of the Docker remote API
    # @param [Number] port the port of the Docker remote API
    # @return [Dockerode]
    # 
    fromHostAndPort: (host, port) ->
      new Dockerode(host: host, port: port)

    # Connect to Docker over socket.
    #
    # @return [Dockerode]
    #
    fromSocket: ->
      socket_path = process.env.DOCKER_SOCKET_PATH
      return undefined unless socket_path
      new Dockerode(socketPath: "#{socket_path}/docker.sock")

    # Get a Docker container.
    #
    # @param [String] id Docker container id
    # @return [Container]
    #
    getContainer: (id) ->
      Promise.promisifyAll(
        @client.getContainer(id)
      ) if id

    # Figure out the host and port from env variables.
    #
    # @return [Array<String,Number>]
    #
    hostAndPort: ->
      if process.env.DOCKER_HOST
        process.env.DOCKER_HOST
          .match(/\w+:\/\/([\d\.]+):(\d+)/)
          .slice(1)
      else
        [ 'http://127.0.0.1', 2375 ]

    # List all Docker containers.
    #
    # @param [Object] params parameters to `Dockerode#listContainers`
    # @return [Array<Object>]
    #
    listContainers: (params) ->
      @client.listContainersAsync(params)

    # List all Docker images.
    #
    # @param [Object] params parameters to `Dockerode#listImages`
    # @return [Array<Object>]
    #
    listImages: (params) ->
      @client.listImagesAsync(params)
