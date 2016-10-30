{CompositeDisposable} = require 'atom'

module.exports = utils =
  views:
    settingsPanel:
      show: (caller) ->
        if !caller.settingsPanel.isVisible()
          caller.servicenowSyncSettingsPanel.urlInputModel.setText ''
          caller.servicenowSyncSettingsPanel.instanceInputModel.setText ''
          caller.servicenowSyncSettingsPanel.tableNameSelect.value = 'placeholder'
          utils.views.settingsPanel.actions.updateFieldSelect caller.servicenowSyncSettingsPanel.tableNameSelect.value, caller
          caller.servicenowSyncSettingsPanel.targetFieldSelect.value = ''
          caller.servicenowSyncSettingsPanel.sysIdInputModel.setText ''
          caller.servicenowSyncSettingsPanel.recordNameInputModel.setText ''
          caller.servicenowSyncSettingsPanel.recordDescriptionInputModel.setText ''
          caller.servicenowSyncSettingsPanel.syncEnabledInput.checked = true
          caller.servicenowSyncSettingsPanel.usernameInputModel.setText ''
          caller.servicenowSyncSettingsPanel.passwordInputModel.setText ''
          utils.views.settingsPanel.actions.setButtonStates caller

          fileSettings = utils.actions.getFileSettings(caller)
          caller.snSettings = fileSettings

          if fileSettings == 401
            return
          caller.settingsPanel.show caller
          caller.settingsPanelSubs.add atom.commands.add 'atom-workspace', 'core:cancel': -> utils.views.settingsPanel.hide caller

          utils.logger.debug '[Servicenow Sync] Created settingsPanel commands'
          caller.servicenowSyncSettingsPanel.instanceInputModel.setText fileSettings?.instance if fileSettings?.instance

          if fileSettings?.table
            caller.servicenowSyncSettingsPanel.tableNameSelect.value = fileSettings.table
            utils.views.settingsPanel.actions.updateFieldSelect caller.servicenowSyncSettingsPanel.tableNameSelect.value, caller, true

          caller.servicenowSyncSettingsPanel.targetFieldSelect.value = fileSettings?.field if fileSettings?.field
          caller.servicenowSyncSettingsPanel.sysIdInputModel.setText fileSettings?.sysId if fileSettings?.sysId
          caller.servicenowSyncSettingsPanel.recordNameInputModel.setText fileSettings?.name if fileSettings?.name
          caller.servicenowSyncSettingsPanel.recordDescriptionInputModel.setText fileSettings?.description if fileSettings?.description
          caller.servicenowSyncSettingsPanel.syncEnabledInput.checked = fileSettings?.syncEnabled
          caller.servicenowSyncSettingsPanel.usernameInputModel.setText fileSettings?.creds?.username if fileSettings?.creds?.username
          caller.servicenowSyncSettingsPanel.passwordInputModel.setText new Buffer(fileSettings?.creds?.password, 'Base64').toString() if fileSettings?.creds?.password
          utils.views.settingsPanel.actions.setButtonStates caller

          caller.servicenowSyncSettingsPanel.focusThis()

      hide: (caller) ->
        if caller.settingsPanel.isVisible()
          caller.settingsPanel.hide()
          caller.settingsPanelSubs.dispose()
          utils.logger.debug '[Servicenow Sync] Disposed settingsPanel commands'

      toggle: (caller) ->
        if caller.settingsPanel.isVisible()
          utils.views.settingsPanel.hide(caller)
        else
          utils.views.settingsPanel.show(caller)

      actions:
        toggleSyncEnabled: (caller) ->
          caller.snSettings.syncEnabled = caller.servicenowSyncSettingsPanel.syncEnabledInput.checked

        getavailableFields: ->
          CSON = require 'season'
          fs = require 'fs'

          thisDir = __dirname
          if process.platform == 'win32'
            pattern = 'lib\\\\modules$'
            tableConfigFile = thisDir.replace(new RegExp(pattern),'config\\tableConfig.cson')
            tableConfigUserFile = thisDir.replace(new RegExp(pattern),'config\\tableConfig.user.cson').replace('\\', '/')
          else
            pattern = 'lib/modules$'
            tableConfigFile = thisDir.replace(new RegExp(pattern),'config/tableConfig.cson')
            tableConfigUserFile = thisDir.replace(new RegExp(pattern),'config/tableConfig.user.cson').replace('\\', '/')
          fs.writeFileSync tableConfigUserFile, '' if not fs.existsSync tableConfigUserFile

          userOut = null
          out = null

          out = CSON.readFileSync tableConfigFile
          userOut = CSON.readFileSync tableConfigUserFile

          combined = Object.assign out, userOut

          combined

        updateFieldSelect: (table, caller, init) ->
          init = false if !init
          caller.snSettings.table = table
          callerPanel = caller.servicenowSyncSettingsPanel
          availableTargetFields = callerPanel.tableConfig[table]
          selectElement = callerPanel.targetFieldSelect

          if availableTargetFields
            if availableTargetFields.length < 1
              selectElement.removeChild(selectElement.firstChild) while selectElement.firstChild
            else
              selectElement.removeChild(selectElement.firstChild) while selectElement.firstChild
              ((val, txt, slct) ->
                option = document.createElement('option')
                option.text = txt
                option.value = val
                slct.appendChild(option)) targetField.field, targetField.displayName, selectElement for targetField in availableTargetFields
              selectElement.value = caller.snSettings.field if init
              caller.snSettings.field = selectElement.value
          else
            selectElement.removeChild(selectElement.firstChild) while selectElement.firstChild

          utils.views.settingsPanel.actions.setButtonStates(caller)

        testUrlInput: (caller) ->
          inputModel = caller.servicenowSyncSettingsPanel.urlInputModel

        parseEnteredUri: (caller) ->
          out =
            instance: null
            table: null
            sysId: null
          uri = caller.servicenowSyncSettingsPanel.urlInputModel.getText()
          if (uri.length > 0)
            out.instance = uri.split('://')[1]?.split('.')[0] or null

            out.table = uri.split('://')[1]?.replace('/nav_to.do?uri=','/').split('service-now.com/')[1]?.split('.')[0] or null
            out.table = null if !caller.servicenowSyncSettingsPanel.tableConfig[out.table]

            out.sysId = uri.split('://')[1]?.split('sys_id=')[1]?.split(/&|%26/)[0] or null

          out

        updateElements: (caller) ->
          formFields =
            instance: null
            table: null
            sysId: null
            username: null
            password: null

          instanceElement = caller.servicenowSyncSettingsPanel.instanceInputModel
          tableElement = caller.servicenowSyncSettingsPanel.tableNameSelect
          sysIdElement = caller.servicenowSyncSettingsPanel.sysIdInputModel
          usernameElement = caller.servicenowSyncSettingsPanel.usernameInputModel
          passwordElement = caller.servicenowSyncSettingsPanel.passwordInputModel

          if caller.servicenowSyncSettingsPanel.urlInputModel.getText().length > 0
            formFields = utils.views.settingsPanel.actions.parseEnteredUri caller

          instanceElement.setText(formFields.instance or '')

          tableName = if caller.servicenowSyncSettingsPanel.tableConfig[formFields.table]?.length then formFields.table else 'placeholder'

          tableElement.value = tableName
          utils.views.settingsPanel.actions.updateFieldSelect(tableElement.value, caller)
          sysIdElement.setText(formFields.sysId or '')
          if formFields.instance?.length and formFields.table?.length and formFields.sysId?.length
            caller.snSettings.instance = formFields.instance
            caller.snSettings.table = formFields.table
            caller.snSettings.sysId = formFields.sysId
          else
            caller.snSettings.instance = null
            caller.snSettings.table = null
            caller.snSettings.sysId = null

          utils.views.settingsPanel.actions.setButtonStates(caller)

        handleUsername: (caller) ->
          username = null
          usernameElement = caller.servicenowSyncSettingsPanel.usernameInputModel
          caller.snSettings.creds?.username = usernameElement.getText() or null
          utils.views.settingsPanel.actions.setButtonStates(caller)

        handlePassword: (caller) ->
          password = null
          passwordElement = caller.servicenowSyncSettingsPanel.passwordInputModel
          encBuffer = new Buffer passwordElement.getText()
          caller.snSettings.creds?.password = encBuffer.toString('base64') or null

          caller.servicenowSyncSettingsPanel.passwordInput.classList.add('occlude') if passwordElement.getText().length > 0
          caller.servicenowSyncSettingsPanel.passwordInput.classList.remove('occlude') if passwordElement.getText().length == 0
          utils.views.settingsPanel.actions.setButtonStates(caller)

        getFieldValue: (value, caller) ->
          caller.snSettings.field = value
          utils.views.settingsPanel.actions.setButtonStates(caller)

        getSysIdValue: (caller) ->
          caller.snSettings.sysId = caller.servicenowSyncSettingsPanel.sysIdInputModel.getText()
          utils.views.settingsPanel.actions.setButtonStates(caller)

        getRecordNameValue: (caller) ->
          caller.snSettings.name = caller.servicenowSyncSettingsPanel.recordNameInputModel.getText()

        getRecordDescriptionValue: (caller) ->
          caller.snSettings.description = caller.servicenowSyncSettingsPanel.recordDescriptionInputModel.getText()

        getInstanceValue: (caller) ->
          caller.snSettings.instance = caller.servicenowSyncSettingsPanel.instanceInputModel.getText()
          utils.views.settingsPanel.actions.setButtonStates(caller)

        setButtonStates: (caller, conditions) ->
          shouldEnable = true

          conditions ?= [
            caller.snSettings.instance?.length > 0
            caller.snSettings.table?.length > 0
            caller.snSettings.creds?.username?.length > 0
            caller.snSettings.creds?.password?.length > 0
          ]

          for condition in conditions
            do (condition) ->
              if condition == false
                shouldEnable = false

          if shouldEnable
            caller.servicenowSyncSettingsPanel.okButton.removeAttribute('disabled')
            shouldEnable = caller.snSettings.sysId?.length > 0
          else
            caller.servicenowSyncSettingsPanel.okButton.setAttribute('disabled', 'true')



          if shouldEnable
            caller.servicenowSyncSettingsPanel.getButton.removeAttribute('disabled')
            caller.servicenowSyncSettingsPanel.pullButton.removeAttribute('disabled')
          else
            caller.servicenowSyncSettingsPanel.getButton.setAttribute('disabled', 'true')
            caller.servicenowSyncSettingsPanel.pullButton.setAttribute('disabled', 'true')

      ui:
        buttons:
          pull:
            click: (caller) ->
              confirm = atom.confirm
                message: "Are you sure?"
                detailedMessage: 'Contents of the currently active tab will be overwritten with the contents of the remote file in Service Now?'
                buttons:
                  Yes: ->
                    caller.editor = atom.workspace.getActiveTextEditor()
                    utils.actions.configureEnvironment [], ->
                      utils.actions.getRemoteFile(caller, caller.servicenowSyncProgress, true, true, (response) ->
                        utils.logger.info '[Servicenow Sync] Get remote file response:'
                        utils.logger.debug(response)
                        snField = response[caller.snSettings.field].replace(/\r\n/g, '\n').replace(/\r/g,'\n')
                        remoteChecksum = utils.actions.checkSum snField
                        caller.snSettings.checksum = remoteChecksum
                        caller.editor.setText snField
                        utils.actions.setFileSettings caller.snSettings
                        utils.logger.debug '[Servicenow Sync] Set fileSettings'
                      )
                    utils.views.settingsPanel.hide caller
                  No: -> utils.views.settingsPanel.show caller

          cancel:
            click: (caller) ->
              utils.logger.debug '[Servicenow Sync] User cancelled the file settings dialog.'
              utils.views.settingsPanel.hide caller

          ok:
            click: (caller) ->
              editor = atom.workspace.getActiveTextEditor()
              caller.snSettings.checksum = utils.actions.checkSum editor.getText().replace(/\r\n/g, '\n').replace(/\r/g,'\n')

              utils.actions.setFileSettings caller.snSettings
              utils.views.settingsPanel.hide caller

          get:
            click: (caller) ->
              utils.actions.configureEnvironment [], ->
                caller.servicenowSyncSettingsPanel.getSpinner.classList.add('icon-spinner')
                caller.servicenowSyncSettingsPanel.getButton.classList.remove('icon-arrow-down')
                caller.snSettings.instance ?= caller.servicenowSyncSettingsPanel.sysIdInputModel.getText()
                caller.snSettings.creds?.username ?= caller.servicenowSyncSettingsPanel.usernameInputModel.getText()
                caller.snSettings.creds?.password ?= caller.servicenowSyncSettingsPanel.passwordInputModel.getText()
                caller.snSettings.table ?= caller.servicenowSyncSettingsPanel.tableNameSelect.value
                caller.snSettings.field ?= caller.servicenowSyncSettingsPanel.targetFieldSelect.value
                utils.logger.warn caller.snSettings
                # caller.snSettings.instance ?= caller.servicenowSyncSettingsPanel.instanceInputModel.getText()
                utils.actions.getRemoteFile(caller, caller.servicenowSyncProgress, false, false, (response) ->
                  caller.snSettings.name = response.name
                  caller.snSettings.description = response.description
                  caller.servicenowSyncSettingsPanel.recordNameInputModel.setText(response.name)
                  caller.servicenowSyncSettingsPanel.recordDescriptionInputModel.setText(response.description) if response.description
                  caller.servicenowSyncSettingsPanel.getSpinner.classList.remove('icon-spinner')
                  caller.servicenowSyncSettingsPanel.getButton.classList.add('icon-arrow-down')
                  editor = atom.workspace.getActiveTextEditor()
                  caller.snSettings.checksum = utils.actions.checkSum editor.getText().replace(/\r\n/g, '\n').replace(/\r/g,'\n')
              )

    progressPanel:
      show: (caller) ->
        if !caller.progressPanel.isVisible()

          caller.progressPanel.show()

      hide: (caller) ->
        if caller.progressPanel.isVisible()
          caller.progressPanel.hide()

      toggle: (caller) ->
        if caller.progressPanel.isVisible()
          utils.views.progressPanel.hide(caller)
        else
          utils.views.progressPanel.show(caller)

      setProgressText: (text, target) ->
        # utils.views.progressPanel.progressText = text
        target.setProgressText(text)
        #
      # progressText: null

  actions:

    getEnv: (envVar, callback) ->
      if process.platform == 'win32'
        envVars = process.env
        for definition of envVars
          key = definition
          value = envVars[definition]
          if key == envVar
            out = {key: key, value: value}

        out = {unset: envVar} if !out
        callback(out)
      else
        ChildProcess = require 'child_process'
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
            if definition
              [key, value] = definition.split('=', 2)
              utils.logger.debug key + ' | ' + value
              if key == envVar
                out = {key: key, value: value}

          out = {unset: envVar} if !out
          callback(out)

    configureEnvironment: (environmentVars = ['http_proxy', 'https_proxy', 'HTTP_PROXY', 'HTTPS_PROXY', 'npm_config_proxy','npm_config_https_proxy','no_proxy','NO_PROXY','all_proxy','ALL_PROXY'], callback)->
      # Here is how we deal with proxy env vars...
      # Adds environmentVars from the OS to the Atom process.env property
      return callback?() if not environmentVars

      # Make sure we have an array, not just a string
      if ! (environmentVars instanceof Array)
        environmentVars = [environmentVars] if environmentVars?.length > 0

      i = 0
      while i < environmentVars.length
        utils.actions.getEnv environmentVars[i], (varObj) ->
          if varObj.key
            if process.env[varObj.key] != varObj.value
              process.env[varObj.key] = varObj.value
              utils.logger.debug '[Servicenow Sync] Set environment variable: ' + varObj.key

          else if varObj.unset
            if process.env[varObj.unset]
              delete process.env[varObj.unset]
              utils.logger.debug '[Servicenow Sync] Unset environment variable: ' + varObj.unset
          return
        i++
      callback?()

    syncFileExists: ->
      require('process')

      postFix = '.snsync.cson'
      fs = require('fs')
      editor = atom.workspace.getActiveTextEditor()
      thisFilePath = editor.getPath()
      syncFilePath = thisFilePath + postFix
      fs.existsSync(syncFilePath)

    checkSum: (input) ->
      crypto = require ('crypto')
      crypto.createHash('sha256')
        .update(utils.actions.handleLineBreaks input.trim())
        .digest('hex')

    handleLineBreaks: (input) ->
      input.replace('\r\n', '\n').replace('\r', '\n')

    getFileSettings: (caller)->
      CSON = require 'season'
      postFix = '.snsync.cson'
      thisFilePath = utils.actions.getFilePath()
      if !thisFilePath
        atom.confirm
          message: 'File not yet saved'
          detailedMessage: 'In order to use Servicenow Sync, you must save this file. Would you like to save it now?'
          buttons:
            Save: (caller) ->
              atom.workspace.saveActivePaneItemAs()

            Cancel: -> thisFilePath = null

      if !thisFilePath
        return 401

      syncFile = thisFilePath + postFix
      requireFile = thisFilePath + postFix
      out =
        instance: ''
        table: ''
        sysId: ''
        field: ''
        name: ''
        description: ''
        creds:
          username: ''
          password: ''
        checksum: ''
        syncEnabled: true
      out = CSON.readFileSync(syncFile) if utils.actions.syncFileExists()
      out

    getFilePath: ->
      fs = require('fs')
      try
        atom.workspace.getActiveTextEditor().getPath()
      catch e
        null

    setFileSettings: (details) ->
      details = {} if !details
      creds = username: null, password: null if !details.creds
      details.instance = null if !details.instance
      details.table = null if !details.table
      details.sysId = null if !details.sysId
      details.field = null if !details.field
      details.name = null if !details.name
      details.description = null if !details.description
      details.creds = creds if !details.creds
      details.instance = null if !details.instance
      details.checksum = null if !details.checksum
      details.syncEnabled = false if !details.syncEnabled

      CSON = require 'season'
      fs = require('fs')
      postFix = '.snsync.cson'
      editor = atom.workspace.getActiveTextEditor()
      thisFilePath = editor.getPath()
      syncFile = thisFilePath + postFix
      requireFile = thisFilePath + postFix
      out = null
      fileConfig =
        instance: details.instance
        table: details.table
        sysId: details.sysId
        field: details.field
        name: details.name
        description: details.description
        creds:
          username: details.creds.username
          password: details.creds.password
        checksum: details.checksum
        syncEnabled: details.syncEnabled

      CSON.writeFileSync syncFile, fileConfig

      utils.actions.setGitIgnore editor.getFileName() + postFix if atom.config.get('servicenow-sync').createGitIgnoreFile
      utils.actions.getFileSettings syncFile

    setGitIgnore: (syncFile) ->
      fs = require('fs')
      syncFile = syncFile.replace /(^[!#])/, '\\$1'
      editor = atom.workspace.getActiveTextEditor()
      thisFilePath = editor.getDirectoryPath()
      gitIgnoreFile = thisFilePath + '/.gitignore'
      if fs.existsSync(gitIgnoreFile)
        appendFile = true
        content = fs.readFileSync(gitIgnoreFile).toString().split('\n')
        for line in content
          if line == syncFile.toString()
            appendFile = false

        fs.appendFileSync gitIgnoreFile, syncFile + '\n' if appendFile
      else
        fs.writeFileSync gitIgnoreFile, syncFile + '\n'

    putFile: (caller, target, content, shouldNotify, callback) ->
      fileSettings = utils.actions.getFileSettings()
      action = if fileSettings?.sysId?.length > 0 then 'update' else 'insert'
      query = if fileSettings?.sysId?.length > 0 then 'sysparm_query=sys_id=' + fileSettings.sysId + '&' else ''
      uri = 'https://' + fileSettings.instance + '.service-now.com/' + fileSettings.table + '.do?' + query + 'sysparm_action=' + action + '&JSONv2'
      data = {}
      data.name = fileSettings.name if fileSettings?.name
      data.description = fileSettings.description if fileSettings?.description

      data[fileSettings.field] = content

      request = require('request')

      auth =
        user: fileSettings.creds.username
        pass: new Buffer(fileSettings.creds.password, 'Base64').toString()
        sendImmediately: false

      options =
        method: 'POST'
        auth: auth
        uri: uri
        body: JSON.stringify(data)

      utils.views.progressPanel.setProgressText 'Pushing local file to https://' + fileSettings.instance + '.service-now.com', target
      utils.views.progressPanel.show(caller)
      request( options, ( error, response, body ) ->
        connectSuccess = true
        querySuccess = true
        recordsFound = 0
        notifyType = 'info'
        notifyDismissable = false
        msg = ''

        if error
          connectSuccess = false
          querySuccess = false
          msg = 'An error occurred pushing ' + fileSettings.name + ' to https://' + fileSettings.instance + '.service-now.com'
          msg += '<br /><strong>Error details:</strong> <em>' + error + '</em>'
          notifyType = 'error'
          notifyDismissable = true
          utils.logger.error(error)

        if connectSuccess and response.statusCode == 200 and JSON.parse(body).error
          parsedOutput = JSON.parse body
          querySuccess = false
          notifyType = 'error'
          notifyDismissable = true
          msg = 'Could not push ' + fileSettings.name + ' to https://' + fileSettings.instance + '.service-now.com'
          msg += '<br /><strong>Error details:</strong> <em>' + parsedOutput.error + '</em>'
          msg += '<br /><strong>Error reason:</strong> <em>' + parsedOutput.reason + '</em>' if parsedOutput.reason

        if connectSuccess and querySuccess and response.statusCode == 200 and JSON.parse(body).records.length == 0
          recordsFound = 0
          notifyType = 'warning'
          notifyDismissable = true
          msg = 'Could not push ' + fileSettings.name + ' to https://' + fileSettings.instance + '.service-now.com'
          msg += '<br /><strong>Error details:</strong> <em>No records were found in table ' + fileSettings.table + ' with sys id of ' + fileSettings.sysId + '</em>'
          utils.logger.warn msg.replace(/<br \/>/g, '\n').replace(/<.+?>/g,'')

        if connectSuccess and querySuccess and response.statusCode == 200 and JSON.parse(body).records.length > 1
          parsedOutput = JSON.parse body
          notifyType = 'warning'
          recordsFound = parsedOutput.records.length
          notifyDismissable = true
          msg = 'Could not push ' + fileSettings.name + ' to https://' + fileSettings.instance + '.service-now.com'
          msg += '<br /><strong>Reason:</strong> <em>More than one record (' + parsedOutput.records.length + ') was returned, please check the file details and try again</em>'
          utils.logger.warn msg.replace(/<br \/>/g, '\n').replace(/<.+?>/g,'')

        if connectSuccess and querySuccess and response.statusCode == 200 and JSON.parse(body).records.length == 1
          parsedOutput = JSON.parse body
          recordsFound = parsedOutput.records.length
          if (JSON.parse body).records[0].__status == 'success'
            notifyType = 'success'
            msg ='Successfully pushed ' + fileSettings.name + ' to https://' + fileSettings.instance + '.service-now.com'
          else
            querySuccess = false
            notifyType = 'error'
            notifyDismissable = true
            msg = 'An error occurred pushing ' + fileSettings.name + ' to https://' + fileSettings.instance + '.service-now.com'

        utils.views.progressPanel.hide caller
        utils.notify[notifyType] msg, dismissable: notifyDismissable if shouldNotify

        return callback? error if !connectSuccess and !querySuccess and recordsFound != 1
        return callback? JSON.parse body if connectSuccess and !querySuccess and recordsFound != 1
        return callback? JSON.parse( body ).records if connectSuccess and querySuccess and recordsFound != 1
        return callback? JSON.parse( body ).records[0] if ( ! error and connectSuccess and querySuccess and recordsFound == 1 and response.statusCode == 200 )
      )

    getRemoteFile: (caller, target, shouldNotify, showProgress, callback) ->
      connectSuccess = true
      querySuccess = true
      recordsFound = 0
      notifyType = 'info'
      notifyDismissable = false
      msg = ''

      fileSettings = utils.actions.getFileSettings() or caller.snSettings
      fileSettings.checksum = caller.snSettings.checksum if fileSettings.checksum == ''
      fileSettings.creds?.username = caller.snSettings.creds?.username if fileSettings.creds?.username == ''
      fileSettings.creds?.password = caller.snSettings.creds?.password if fileSettings.creds?.password == ''
      fileSettings.description = caller.snSettings.description if fileSettings.description == ''
      fileSettings.field = caller.snSettings.field if fileSettings.field == ''
      fileSettings.instance = caller.snSettings.instance if fileSettings.instance == ''
      fileSettings.name = caller.snSettings.name if fileSettings.name == ''
      fileSettings.sysId = caller.snSettings.sysId if fileSettings.sysId == ''
      fileSettings.table = caller.snSettings.table if fileSettings.table == ''

      utils.logger.info fileSettings
      if fileSettings.instance and fileSettings.table and fileSettings.sysId and fileSettings.creds.username and fileSettings.creds.password
        uri = 'https://' + fileSettings.instance + '.service-now.com/' + fileSettings.table + '.do?sysparm_query=sys_id=' + fileSettings.sysId + '&JSONv2'
      else
        return alert 'Could not verify enough settings to retrieve the file settings from your Service Now instance'

      request = require('request')

      auth = auth:
        user: fileSettings.creds.username
        pass: new Buffer(fileSettings.creds.password, 'Base64').toString()
        sendImmediately: false

      if showProgress
        utils.views.progressPanel.setProgressText 'Retrieving remote file from https://' + fileSettings.instance + '.service-now.com', target
        utils.views.progressPanel.show(caller)

      request( uri, auth, ( error, response, body ) ->
        if error
          connectSuccess = false
          querySuccess = false
          msg = 'An error occurred retrieving ' + fileSettings.name + ' from https://' + fileSettings.instance + '.service-now.com'
          msg += '<br /><strong>Error details:</strong> <em>' + error + '</em>'
          notifyType = 'error'
          notifyDismissable = true
          shouldNotify = true
          utils.logger.error(error)

        if connectSuccess and response.statusCode == 200 and JSON.parse(body).error
          parsedOutput = JSON.parse body
          querySuccess = false
          notifyType = 'error'
          notifyDismissable = true
          shouldNotify = true
          msg = 'Could not retrieve ' + fileSettings.name + ' from https://' + fileSettings.instance + '.service-now.com'
          msg += '<br /><strong>Error details:</strong> <em>' + parsedOutput.error + '</em>'
          msg += '<br /><strong>Error reason:</strong> <em>' + parsedOutput.reason + '</em>' if parsedOutput.reason

        if connectSuccess and querySuccess and response.statusCode == 200 and JSON.parse(body).records.length == 0
          recordsFound = 0
          notifyType = 'warning'
          notifyDismissable = true
          shouldNotify = true
          msg = 'Could not retrieve ' + fileSettings.name + ' from https://' + fileSettings.instance + '.service-now.com'
          msg += '<br /><strong>Error details:</strong> <em>No records were found in table ' + fileSettings.table + ' with sys id of ' + fileSettings.sysId + '</em>'
          utils.logger.warn msg.replace(/<br \/>/g, '\n').replace(/<.+?>/g,'')

        if connectSuccess and querySuccess and response.statusCode == 200 and JSON.parse(body).records.length > 1
          parsedOutput = JSON.parse body
          notifyType = 'warning'
          recordsFound = parsedOutput.records.length
          notifyDismissable = true
          shouldNotify = true
          msg = 'Could not retrieve ' + fileSettings.name + ' from https://' + fileSettings.instance + '.service-now.com'
          msg += '<br /><strong>Reason:</strong> <em>More than one record (' + parsedOutput.records.length + ') was returned, please check the file details and try again</em>'
          utils.logger.warn msg.replace(/<br \/>/g, '\n').replace(/<.+?>/g,'')

        if connectSuccess and querySuccess and response.statusCode == 200 and JSON.parse(body).records.length == 1
          parsedOutput = JSON.parse body
          recordsFound = parsedOutput.records.length
          if (JSON.parse body).records[0].__status == 'success'
            notifyType = 'success'
            msg ='Successfully retrieved ' + fileSettings.name + ' from https://' + fileSettings.instance + '.service-now.com'
          else
            querySuccess = false
            notifyType = 'error'
            notifyDismissable = true
            msg = 'An error occurred retrieving ' + fileSettings.name + ' from https://' + fileSettings.instance + '.service-now.com'

        utils.views.progressPanel.hide caller if showProgress
        utils.notify[notifyType] msg, dismissable: notifyDismissable if shouldNotify

        return callback? error if !connectSuccess and !querySuccess and recordsFound != 1
        return callback? JSON.parse body if connectSuccess and !querySuccess and recordsFound != 1
        return callback? JSON.parse( body ).records if connectSuccess and querySuccess and recordsFound != 1
        return callback? JSON.parse( body ).records[0] if ( ! error and connectSuccess and querySuccess and recordsFound == 1 and response.statusCode == 200 )
      )

    confirmNewSNFile: (caller) ->
      confirm = atom.confirm
        message: "No Service Now settings exist."
        detailedMessage: 'Would you like to configure this file for ServiceNow Sync?'
        buttons:
          Yes: -> utils.views.settingsPanel.show caller
          No: -> return false

    confirmFileDiff: (caller) ->
      confirm = atom.confirm
        message: "Content Mismatch!"
        detailedMessage: 'The remote file checksum does not match the local one.\nThis file may have been edited externally.\n Would you like to continue?'
        buttons:
          Yes: -> return true
          No: -> return false

    configurePushOnSave: (caller) ->
      caller.onSaveSubs ?= new CompositeDisposable
      caller.configSubs ?= new CompositeDisposable

      caller.onSaveSubs.add atom.workspace.observeTextEditors (editor) ->
        @editorSubs = new CompositeDisposable
        caller.onSaveSubs.add @editorSubs
        @editorSubs.add editor.onDidSave ->
          if atom.config.get('servicenow-sync').pushOnSave and utils.actions.syncFileExists()
            caller.sync(true)
        @editorSubs.add editor.onDidDestroy ->
          @editorSubs.dispose()
          @editorSubs.clear()

    viewRemoteFile: (caller) ->
      if !utils.actions.syncFileExists()
        utils.actions.confirmNewSNFile caller
      else
        # @editor = atom.workspace.getActiveTextEditor()
        fileSettings = utils.actions.getFileSettings caller

        if fileSettings?.sysId?.length > 0 and fileSettings?.instance?.length > 0 and fileSettings?.table?.length > 0
          uri = 'https://' + fileSettings?.instance + '.service-now.com/nav_to.do?uri=' + fileSettings?.table + '.do?sys_id=' + fileSettings?.sysId
          shell = require 'shell'
          shell.openExternal uri
        else
          utils.logger.warn '[Servicenow Sync] This file is missing configuration items. Run servicenow-sync:configure-file from the command pallet to change this files config'
          utils.notify.warning 'This file is missing configuration items. <br />Run <strong>servicenow-sync:configure-file</strong> from the command pallet to change this files config'

  logger:
    debug: (msg) -> console.debug msg if atom.config.get('servicenow-sync').debug
    error: (msg) -> console.error msg #if atom.config.get('servicenow-sync').debug
    info: (msg) -> console.info msg if atom.config.get('servicenow-sync').debug
    log: (msg) -> console.log msg if atom.config.get('servicenow-sync').debug
    warn: (msg) -> console.warn msg #if atom.config.get('servicenow-sync').debug

  notify:
    error: (msg, options) -> atom.notifications.addError(msg, options)
    fatalerror: (msg, options) -> atom.notifications.addFatalError(msg, options)
    info: (msg, options) -> atom.notifications.addInfo(msg, options)
    success: (msg, options) -> atom.notifications.addSuccess(msg, options)
    warning: (msg, options) -> atom.notifications.addWarning(msg, options)
