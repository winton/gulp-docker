Promise = require("bluebird")
Docker  = require("../../../lib/docker")

describe "Sidekick", ->

  beforeAll ->
    @subject = new Docker.Args(
      "sidekick"
      env:
        DOCKER_SOCKET_PATH: "/var/run"
        ENV: "production"
    )

  describe "cliParams", ->

    beforeEach ->
      @subject = @subject.cliParams()

    it "generates CLI parameters", ->
      expect(@subject).toEqual([
        '--name'
        'sidekick'
        '-e'
        'DOCKER_SOCKET_PATH=/var/run/host'
        '-e'
        'ENV=production'
        '-v'
        '/var/run:/var/run/host'
        'repo'
        'bin/sidekick'
      ])