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
        app_sha:   "git rev-parse HEAD"
        clone_app:
          """
          git clone -b #{@container.branch} \
            --single-branch #{@container.git} \
            .tmp/#{@container.name}
          """
        mkdir_app: "mkdir -p .tmp/#{@container.name}"
        rmrf_app:  "rm -rf .tmp/#{@container.name}"

    # Gets the sha of the app code.
    #
    # @return [Promise<String>] promise that resolves when command
    #   finishes 
    #
    appSha: ->
      spawnOut(@commands.app_sha)

    # Builds an image.
    #
    # @return [Promise<String,Number>] the output and exit code
    #
    build: ->
      props = {}

      @rmrfApp().then(
        => @mkdirApp()
      ).then(
        => @cloneApp()
      ).then(
        => @appSha()
      ).then(
        (sha) => @buildImage(props, sha)
      ).then(
        => @runPostBuild(props)
      ).then(
        => @waitForFinish(props)
      ).then(
        => @commitContainer(props)
      ).then(
        => @tagContainer(props)
      ).then(
        => @pushImage(props)
      )

    # Runs `docker build` on the app code.
    #
    # @param [Object] props shared properties from `build`
    # @param [String] sha the sha of the app code
    # @return [Promise] promise that resolves when command finishes 
    #
    buildImage: (props, sha) ->
      props.sha      = sha.substring(0,8)
      @container.tag = props.sha

      spawn(@buildImageCommand(props.sha))

    # Generates the `docker build` command.
    #
    # @param [String] sha the git sha hash of the project
    # @return [String] the docker build command
    #
    buildImageCommand: (sha) ->
      """
      docker build \
        -t #{@container.repo}:#{sha} \
        .tmp/#{@container.name}
      """

    # Check `docker ps` for the existence of a container sha.
    #
    # @param [String] run_sha the sha of the container
    # @return [Promise] promise that resolves when command finishes 
    #
    checkContainerSha: (run_sha) ->
      run_sha = run_sha.substring(0, 12)
      spawnOut("docker ps").then(
        (output) =>
          !!output.match(///#{run_sha}\s+///g)
      )

    # Start a timer to continually check if a container finished
    # running.
    #
    # @param [String] run_sha the sha of the container
    # @param [Function] resolve the function to run once the
    #   container is found
    # @return [Number] `setTimeout` id
    #
    checkFinished: (run_sha, resolve) ->
      setTimeout(
        =>
          process.stdout.write(".")

          @checkContainerSha(run_sha).then (found) =>
            if found
              @checkFinished(run_sha, resolve)
            else
              console.log ""
              resolve()
        1*1000
      )

    # Clone the app code into `.tmp`.
    #
    # @return [Promise] promise that resolves when command finishes 
    #
    cloneApp: ->
      spawnOut(@commands.clone_app)

    # Command to commit the container generated from the post build
    # command.
    #
    # @param [String] run_sha the sha of the container
    #
    commitCommand: (run_sha) ->
      "docker commit #{run_sha} #{@container.repo}"

    # Commit the container if a post build command executed.
    #
    # @param [Object] props shared properties from `build`
    # @return [Promise] promise that resolves when command finishes
    #
    commitContainer: (props) ->
      if @container.build
        spawn(@commitCommand(props.run_sha))

    # Makes the directory to house the app code within `.tmp`.
    #
    # @return [Promise] promise that resolves when command finishes 
    #
    mkdirApp: ->
      spawnOut(@commands.mkdir_app)

    # Pushes the docker image to the registry.
    #
    # @param [Object] props shared properties from `build`
    # @return [Promise] promise that resolves when command finishes 
    #
    pushImage: (props) ->
      if @container.push
        spawn(@pushImageCommand(props.sha))

    # Generates the `docker push` command.
    #
    # @param [String] sha the git sha hash of the project
    # @return [String] the docker push command
    #
    pushImageCommand: (sha) ->
      "docker push #{@container.repo}:#{sha}"

    # Remove the app code in the `.tmp` directory.
    #
    # @return [Promise] promise that resolves when command finishes 
    #
    rmrfApp: ->
      spawnOut(@commands.rmrf_app)

    # Run the post build command.
    #
    # @param [Object] props shared properties from `build`
    # @return [Promise] promise that resolves when command finishes 
    #
    runPostBuild: (props) ->
      container = new Docker.Container(@container, "build")

      if @container.build
        container.run().then(
          (output) -> props.run_sha = output.id
        )

    # Generates the `docker tag` command.
    #
    # @param [String] source the source tag
    # @param [String] dest the destination tag
    # @return [String] the docker tag command
    #
    tagCommand: (source, dest="latest") ->
      """
      docker tag \
        #{@container.repo}:#{source} \
        #{@container.repo}:#{dest}
      """

    # Tag the image.
    #
    # @param [Object] props shared properties from `build`
    # @return [Promise] promise that resolves when command finishes
    #
    tagContainer: (props) ->
      if @container.build
        spawnOut(@tagCommand("latest", props.sha))
      else
        spawnOut(@tagCommand(props.sha))

    # Wait for post build commands to finish.
    #
    # @param [Object] props shared properties from `build`
    # @return [Promise] promise that resolves when command finishes
    #
    waitForFinish: (props) ->
      process.stdout.write "Waiting for post build command to finish"

      new Promise (resolve) =>
        @checkFinished(props.run_sha, resolve)