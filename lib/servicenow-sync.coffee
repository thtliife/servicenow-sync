ServicenowSyncView = require './servicenow-sync-view'
{CompositeDisposable} = require 'atom'

module.exports = ServicenowSync =
  servicenowSyncView: null
  modalPanel: null
  subscriptions: null
  #config:


  activate: (state) ->
    # console.log 'Loaded Servicenow Sync Package'
    @servicenowSyncView = new ServicenowSyncView(state.servicenowSyncViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @servicenowSyncView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'servicenow-sync:toggle': => @toggle()
    @subscriptions.add atom.commands.add 'atom-workspace', 'servicenow-sync:syncFileExists': => @fileInfo()



  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @servicenowSyncView.destroy()

  serialize: ->
    servicenowSyncViewState: @servicenowSyncView.serialize()

  toggle: ->
    # console.log 'ServicenowSync was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      editor = atom.workspace.getActiveTextEditor()
      @modalPanel.show()

  sync: (proxyAddr) ->
    useProxy = if proxyAddr then true else false
    console.info(useProxy)

  fileInfo: ->
    # alert(ServicenowSync.syncFileExists())

    # console.debug(process.env)
    # console.info(ServicenowSync.syncFileExists())
    ServicenowSync.getEnv('http_proxy',(envVar) => ServicenowSync.sync(envVar))


  # region Utility Functions
  syncFileExists: ->
    require('process')

    postFix = '.snsync.cson'
    fs = require('fs')
    editor = atom.workspace.getActiveTextEditor()
    thisFilePath = editor.getPath()
    syncFilePath = thisFilePath + postFix
    if !fs.existsSync(syncFilePath) then false else true

  getEnv: (envVar, callback) ->
    ChildProcess = require 'child_process'
    # I tried using ChildProcess.execFile but there is no way to set detached and this causes the child shell to lock up. This command runs an interactive login shell and executes the export command to get a list of environment variables. We then use these to run the script:
    child = ChildProcess.spawn process.env.SHELL, ['-ilc', 'printenv'],
      # This is essential for interactive shells, otherwise it never finishes:
      detached: true,
      # We don't care about stdin, stderr can go out the usual way:
      stdio: ['ignore', 'pipe', process.stderr]

    # We buffer stdout:
    buffer = ''
    child.stdout.on 'data', (data) -> buffer += data
    out = null
    # When the process finishes, extract the environment variables and pass them to the callback:
    child.on 'close', (code, signal) ->
      for definition in buffer.split('\n')
        [key, value] = definition.split('=', 2)
        # console.warn(key)
        out = value if key == envVar
          # out = value
        # value
      callback(out)

  # endregion Utility Functions
