Promise  = require "bluebird"
readline = require "readline"

module.exports = (GulpDocker) -> 

  # Gathers input from the user.
  #
  class GulpDocker.Ask

    # Asks a question and tests the answer.
    #
    # @param [String] question the question to ask
    # @param [RegExp] format the test for the answer
    # @return [Promise<String>] the answer
    #
    ask: (question, format) ->
      @question(question).then (answer) =>
        if !format || format.test(answer)
          answer
        else
          console.log "\nIt should match: #{format}\n"
          @ask(question, format)

    # Starts up the readline interface and asks the question.
    #
    # @param [String] question the question to ask
    # @return [Promise<String>] the answer
    # 
    question: (question) ->
      rl = @readlineInterface()

      new Promise((resolve) ->
        rl.question "\n#{question} ", (answer) ->
          rl.close()
          resolve(answer)
      )

    # Creates a readline `Interface` instance.
    #
    # @return [Interface]
    # 
    readlineInterface: ->
      readline.createInterface(
        input:  process.stdin
        output: process.stdout
      )
