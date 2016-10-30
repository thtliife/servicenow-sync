ServicenowSyncProgress = require './views/servicenow-sync-progress'
ServicenowSyncSettingsPanel = require './views/servicenow-sync-settings-panel'
utils = require './modules/servicenow-sync-utils'

{CompositeDisposable} = require 'atom'

# update this once localization module is done.
userLanguage = (lang = 'en_US')->
  if lang.hasOwnProperty( process.env.LANG.split('.')[0] )
    process.env.LANG.split('.')[0]
  else
    'en_US'

module.exports = ServicenowSync =
  servicenowSyncSettingsPanel: null
  servicenowSyncProgress: null
  settingsPanel: null
  progressPanel: null
  subscriptions: new CompositeDisposable
  settingsPanelSubs: new CompositeDisposable
  onSaveSubs: new CompositeDisposable
  configSubs: new CompositeDisposable
  progressText: null
  editor: null
  remoteFile: null
  snSettings:
    instance: null
    table: null
    sysId: null
    field: null
    name: null
    description: null
    creds:
      username: null
      password: null
    checksum: null

  config:
    pushOnSave:
      title: 'Sync on save'
      description: 'Selecting this option will cause the plugin to upload directly.'
      type: 'boolean'
      default: false
      order: 0
    createGitIgnoreFile:
      title: 'Create .gitignore'
      description: 'Create a .gitignore file in the files path, to ignore the .snsync.cson file. (Recommended as Servicenow credentials are stored here)'
      type: 'boolean'
      default: true
      order: 1
    debug:
      title: 'Debug mode'
      description: 'Selecting debug mode will cause the plugin to output operations to console.'
      type: 'boolean'
      default: false
      order: 2

  activate: (state) ->

    @servicenowSyncSettingsPanel = new ServicenowSyncSettingsPanel(state.servicenowSyncSettingsPanelState, ServicenowSync)
    @servicenowSyncProgress = new ServicenowSyncProgress(state.servicenowSyncProgressState, ServicenowSync)
    @settingsPanel = atom.workspace.addModalPanel(item: @servicenowSyncSettingsPanel.getElement(), visible: false)
    @progressPanel = atom.workspace.addModalPanel(item: @servicenowSyncProgress.getElement(), visible: false)

    @subscriptions.add atom.commands.add 'atom-workspace', 'servicenow-sync:configure-file': => @configPanel()
    @subscriptions.add atom.commands.add 'atom-workspace', 'servicenow-sync:sync': => @sync()
    @subscriptions.add atom.commands.add 'atom-workspace', 'servicenow-sync:view-remote': => @viewRemote()

    utils.actions.configurePushOnSave ServicenowSync
    utils.actions.configureEnvironment()

  deactivate: ->
    @settingsPanel.destroy()
    @progressPanel.destroy()

    @subscriptions.dispose()
    @settingsPanelSubs.dispose()
    @onSaveSubs?.dispose()

  serialize: ->
    servicenowSyncSettingsPanelState: @servicenowSyncSettingsPanel.serialize()

  sync: (initiatedBySave)->

    if !utils.actions.syncFileExists()
      utils.actions.confirmNewSNFile ServicenowSync
    else
      @editor = atom.workspace.getActiveTextEditor()
      @snSettings = utils.actions.getFileSettings ServicenowSync
      if !@snSettings.syncEnabled
        utils.logger.warn  '[Servicenow Sync] Sync is disabled for this file. Run servicenow-sync:configure-file from the command pallet to change this files config'
        utils.notify.warning 'Sync is disabled for this file. <br />Run <strong>servicenow-sync:configure-file</strong> from the command pallet to change this files config', dismissable: false if !initiatedBySave
        return
      utils.actions.configureEnvironment ['http_proxy', 'https_proxy', 'HTTP_PROXY', 'HTTPS_PROXY', 'npm_config_proxy','npm_config_https_proxy','no_proxy','NO_PROXY','all_proxy','ALL_PROXY'], ->
        if ServicenowSync.snSettings?.sysId?.length > 0
          utils.actions.getRemoteFile(ServicenowSync, ServicenowSync.servicenowSyncProgress, false, true, (response) ->
            return if response.length == 0
            remoteContent = response[ServicenowSync.snSettings.field]?.replace(/\r\n/g, '\n').replace(/\r/g,'\n')
            remoteChecksum = utils.actions.checkSum remoteContent
            localChecksum = ServicenowSync.snSettings.checksum
            if remoteChecksum != localChecksum
              if !utils.actions.confirmFileDiff ServicenowSync
                utils.notify.warning 'Sync to service now cancelled by user', dismissable: false
                return

            ServicenowSync.push()
          )
        else
          ServicenowSync.push()


  push: () ->
    fileSettings = utils.actions.getFileSettings ServicenowSync
    if fileSettings.syncEnabled && fileSettings.instance && fileSettings.table && fileSettings.field && fileSettings.creds.username && fileSettings.creds.password
      editor = atom.workspace.getActiveTextEditor()
      content = editor.buffer.getText()
      utils.actions.configureEnvironment [], ->
        utils.actions.putFile(ServicenowSync, ServicenowSync.servicenowSyncProgress, content, true, (response) ->
          remoteContent = response[fileSettings.field].replace(/\r\n/g, '\n').replace(/\r/g,'\n')
          remoteChecksum = utils.actions.checkSum remoteContent
          ServicenowSync.snSettings.checksum = remoteChecksum
          ServicenowSync.snSettings.sysId = response.sys_id if !ServicenowSync.snSettings?.sysId?.length > 0
          utils.actions.setFileSettings ServicenowSync.snSettings

          utils.logger.info '[Servicenow Sync] push response:'
          utils.logger.debug(response)
        )

  configPanel: ->

    # Show the file settings panel
    utils.views.settingsPanel.toggle ServicenowSync

  viewRemote: ->
    utils.actions.viewRemoteFile ServicenowSync
