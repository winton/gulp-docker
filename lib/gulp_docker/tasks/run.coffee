GulpDocker = require "../../gulp-docker"

module.exports = (gulp, containers) ->

  gulp.task "docker:run", ->
    new GulpDocker.Docker(containers).run()
