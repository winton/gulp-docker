GulpDocker = require "../../gulp-docker"

module.exports = (gulp, containers) ->

  gulp.task "docker:restart", ->
    new GulpDocker.Docker(containers).restart()
