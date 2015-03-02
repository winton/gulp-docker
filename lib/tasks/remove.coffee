spawn    = require("../spawn")()
spawnOut = require("../spawn")("inherit")

module.exports = (gulp, containers) ->

  removeImages = ->
    spawn("docker images -q").then (output) ->
      spawnOut("docker rmi -f #{output}")

  removeInstances = ->
    spawn("docker ps -a -q").then (output) ->
      spawnOut("docker rm -f #{output}")

  gulp.task "docker:remove:all", ->
    removeInstances().then -> removeImages()

  gulp.task "docker:remove:images", ->
    removeImages()

  gulp.task "docker:remove:instances", ->
    removeInstances()
