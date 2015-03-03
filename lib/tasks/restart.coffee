Docker = require "../docker"

module.exports = (gulp, containers) ->

  gulp.task "docker:restart", ->
    new Docker(containers).restart()