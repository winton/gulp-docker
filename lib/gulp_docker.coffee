requireDirectory = require("require-directory")

# Adds Docker tasks to Gulp.
#
class GulpDocker

  # Load gulp tasks. Silence gulp if necessary.
  #
  # @param [Object] @gulp instance of gulp
  # @param [Object] @containers container information object
  #
  constructor: (@gulp, @containers) ->
    @tasks = requireDirectory(module, "./gulp_docker/tasks")
    fn(@gulp, @containers) for task, fn of @tasks

  # Convenience method for subclasses to ask questions from
  # the user.
  #
  # @param [String] question question to ask user
  # @param [RegExp] format the format you expect for the answer
  # @return [Promise<String>] the answer
  #
  @ask: (question, format) ->
    new GulpDocker.Ask().ask(question, format)

require("./gulp_docker/ask")(GulpDocker)
require("./gulp_docker/docker")(GulpDocker)

module.exports = GulpDocker
