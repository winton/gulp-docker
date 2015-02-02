Docker = require "../docker"

module.exports = (gulp, containers) ->

  gulp.task "docker:image", ->
    new Docker(containers).image()