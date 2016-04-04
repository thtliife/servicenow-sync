ServicenowSyncView = require './servicenow-sync-view'
{CompositeDisposable} = require 'atom'
module.exports = ServicenowSync =
  servicenowSyncView: null
  modalPanel: null
  subscriptions: null
  config:
    useProxy:
      title: 'Connect through a proxy server?'
      description: 'Select this option if you use a proxy to connect to the internet.'
      type: 'boolean'
      default: false
      order: 1
    proxyDetails:
      requireAuth:
        title: 'Proxy requires Authentication'
        description: 'Select this option if your proxy requires authentication.'
        type: 'boolean'
        default: false
        order: 2

  activate: (state) ->
    console.log 'Loaded Servicenow Sync Package'
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
    console.log 'ServicenowSync was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      editor = atom.workspace.getActiveTextEditor()
      content = editor.getText()
      # words = editor.getText().split(/\s+/).length
      # @servicenowSyncView.setCount(words)
      @servicenowSyncView.contentToModal(content)
      @modalPanel.show()

  fileInfo: ->
    alert(ServicenowSync.syncFileExists())

  syncFileExists: ->
    postFix = '.snsync.cson'
    fs = require('fs')
    editor = atom.workspace.getActiveTextEditor()
    thisFilePath = editor.getPath()
    syncFilePath = thisFilePath + postFix
    if !fs.existsSync(syncFilePath)
      return false
    return true
