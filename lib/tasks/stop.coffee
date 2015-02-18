Docker = require "../docker"

module.exports = (gulp, containers) ->

  gulp.task "docker:stop", ->
    new Docker(containers).stop()