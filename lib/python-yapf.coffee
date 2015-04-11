fs = require 'fs'
$ = require('atom').$
process = require 'child_process'

module.exports =
class PythonYAPF

  checkForPythonContext: ->
    editor = atom.workspace.getActiveEditor()
    if not editor?
      return false
    return editor.getGrammar().name == 'Python'

  removeStatusbarItem: =>
    @statusBarTile?.destroy()
    @statusBarTile = null

  updateStatusbarText: (message, isError) =>
    if not @statusBarTile
      statusBar = document.querySelector("status-bar")
      return unless statusBar?
      @statusBarTile = statusBar
        .addLeftTile(
          item: $('<div id="status-bar-python-yapf" class="inline-block">
                    <span style="font-weight: bold">YAPF: </span>
                    <span id="python-yapf-status-message"></span>
                  </div>'), priority: 100)

    statusBarElement = @statusBarTile.getItem()
      .find('#python-yapf-status-message')

    if isError == true
      statusBarElement.addClass("text-error")
    else
      statusBarElement.removeClass("text-error")

    statusBarElement.text(message)

  getFilePath: ->
    editor = atom.workspace.getActiveEditor()
    return editor.getPath()

  checkFormat: ->
    if not @checkForPythonContext()
      return

    params = [@getFilePath(), "-d"]
    yapfPath = atom.config.get "python-yapf.yapfPath"

    which = process.spawnSync('which', ['yapf']).status
    if which == 1 and not fs.existsSync(yapfPath)
      @updateStatusbarText("unable to open " + yapfPath, false)
      return

    proc = process.spawn yapfPath, params

    updateStatusbarText = @updateStatusbarText
    proc.on 'exit', (exit_code, signal) ->
      if exit_code == 0
        updateStatusbarText("√", false)
      else
        updateStatusbarText("x", true)

  formatCode: ->
    if not @checkForPythonContext()
      return

    params = [@getFilePath(), "-i"]
    yapfPath = atom.config.get "python-yapf.yapfPath"

    which = process.spawnSync('which', ['yapf']).status
    if which == 1 and not fs.existsSync(yapfPath)
      @updateStatusbarText("unable to open " + yapfPath, false)
      return

    proc = process.spawn yapfPath, params
    @updateStatusbarText("√", false)
    @reload