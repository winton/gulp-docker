GulpDocker = require "../../gulp-docker"

module.exports = (gulp, containers) ->

  gulp.task "docker:image", ->
    new GulpDocker.Docker(containers).image()
