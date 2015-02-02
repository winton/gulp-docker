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

    # Create a Docker container.
    #
    # @param [Object] params parameters to `Dockerode#createContainer`
    # @return [Container]
    #
    createContainer: (params) ->
      @client.createContainerAsync(params)

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