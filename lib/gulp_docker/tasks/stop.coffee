GulpDocker = require "../../gulp-docker"

module.exports = (gulp, containers) ->

  gulp.task "docker:stop", ->
    new GulpDocker.Docker(containers).stop()
