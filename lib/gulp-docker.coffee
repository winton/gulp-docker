requireDirectory = require("require-directory")

# Configures Docker containers and adds tasks to Gulp.
#
class GulpDocker

  # Load gulp tasks. Silence gulp if necessary.
  #
  # @param [Object] @gulp instance of gulp
  # @param [Object] @containers container information object
  # @example
  #   gulp = require("gulp");
  #   new GulpDocker(gulp, {
  #     sidekick: {
  #       app:  "git@github.com:winton/sidekick.git#release",
  #       run:  "bin/sidekick",
  #       env:  { ENV: "production" },
  #       repo: "quay.io/winton/sidekick"
  #     }
  #   });
  #
  constructor: (@gulp, @containers) ->
    @silenced = []
    @tasks    = requireDirectory(module, "./tasks")
    
    fn(@gulp, @containers) for task, fn of @tasks

    if @silenced.indexOf(process.argv[2]) > -1
      @turnOffGulpOutput()

  # Silences gulp output, while still allowing `console.log` from tasks.
  #
  # @param [String] task task name to silence gulp output for
  #
  silence: (task) ->
    @silenced.push task

  # Shortcut for `gulp.task` that silences gulp output.
  #
  # @param [String] task task name
  # @param [Function] fn task function
  #
  silentTask: (task, fn) ->
    @silence(task)
    @gulp.task(task, fn)

  # Turn off gulp console output.
  #
  turnOffGulpOutput: ->
    @log = console.log

    console.log = =>
      args = Array::slice.call(arguments)
      return if args.length && /^\[/.test(args[0])
      @log.apply console, args

  # Turn on gulp console output.
  #
  turnOnGulpOutput: ->
    console.log = @log if @log

module.exports = GulpDocker