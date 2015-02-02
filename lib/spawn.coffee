child_process = require("child_process")
path          = require("path")
Promise       = require("bluebird")

# Execute system commands and record output.
#
# @example
#   spawn = require("spawn")
#   spawn("pwd").then (output, exit_code) ->
#     # do something with output
#
class Spawn

  # @param [Object] options `child_process.spawn` options
  # @option options [String] stdio `pipe`, `ignore`, or `inherit`
  # @option options [String] cwd current working directory of the child process
  #
  constructor: (@options={}) ->
    @options.stdio ||= "pipe"
    @options.cwd     = path.normalize(
      "#{__dirname}/../#{@options.cwd || ""}"
    )

  # @param [String] cmd command to execute
  # @return [ChildProcess]
  #
  childProcess: (cmd) ->
    cmd = cmd.split(/\s+/)

    child_process.spawn(
      cmd.shift()
      cmd
      @options
    )

  # Promisify `child_process.spawn`.
  #
  # @param [String] cmd command to execute
  # @return [Promise<String,Number>]
  #
  spawn: (cmd) ->
    proc   = @childProcess(cmd)
    output = ""

    if proc.stdout
      proc.stdout.on "data", (data) ->
        output += data

      proc.stderr.on "data", (data) ->
        output += data

    new Promise (resolve, reject) ->
      proc.on 'close', (code) ->
        resolve(output, code)

module.exports = (new Spawn()).spawn