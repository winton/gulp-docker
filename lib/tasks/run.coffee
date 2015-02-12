Docker = require "../docker"

module.exports = (gulp, containers) ->

  gulp.task "docker:run", ->
    new Docker(containers).run()