ServicenowSyncView = require './servicenow-sync-view'
{CompositeDisposable} = require 'atom'

module.exports = ServicenowSync =
  servicenowSyncView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @servicenowSyncView = new ServicenowSyncView(state.servicenowSyncViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @servicenowSyncView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'servicenow-sync:toggle': => @toggle()

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
      @modalPanel.show()
