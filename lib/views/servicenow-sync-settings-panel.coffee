{CompositeDisposable} = require 'atom'
utils = require '../modules/servicenow-sync-utils'

module.exports =
class ServicenowSyncSettingsPanel
  constructor: (serializedState, parent) ->
    @urlInputModel = null
    @instanceInputModel = null
    @tableNameInputModel = null
    @targetInputModel = null
    @sysIdInputModel = null
    @recordNameInputModel = null
    @recordDescriptionInputModel = null
    @usernameInputModel = null
    @passwordInputModel = null
    @data = @urlInputModel
    @tableConfig = utils.views.settingsPanel.actions.getavailableFields()
    @focusThis = -> urlInput.focus()

    # Create root element
    @element = document.createElement('div')
    @element.classList.add('servicenow-sync')

    # Create the main form element
    form = document.createElement('div', 'controls')
    @element.appendChild(form)

    # Create the title
    title = document.createElement('h2')
    title.classList.add('centered')
    title.textContent = 'Configure this file for Service Now Sync'
    form.appendChild(title)

    # Create the div for the url input
    urlDiv = document.createElement('div')
    urlDiv.classList.add('control-group', 'url-div')
    form.appendChild(urlDiv)

    # Create the label for the url input
    urlLabel = document.createElement('label')
    urlLabel.textContent = 'Service Now file URL:'
    urlLabel.classList.add('url-label','icon','icon-globe')
    urlLabel.setAttribute('for','url-input')
    urlDiv.appendChild(urlLabel)

    # Create the span to hold the url input
    urlSpan = document.createElement('span')
    urlSpan.classList.add('url-span')
    urlDiv.appendChild(urlSpan)

    # Create the url input
    urlInput = document.createElement('atom-text-editor')
    urlInput.classList.add('url-input','input')
    urlInput.setAttribute('id', 'url-input')
    urlInput.setAttribute('type', 'text')
    urlInput.setAttribute('mini', 'true')
    urlInput.setAttribute('tabindex', '1')
    urlInput.setAttribute('placeholder-text', 'Paste the Scripts Service Now URL here...')
    @urlInputModel = urlInput.getModel()
    urlSpan.appendChild(urlInput)

    # Create the get info button
    @getButton = document.createElement('button')
    @getButton.classList.add('form-control','btn','btn-get','icon','icon-arrow-down')
    @getButton.addEventListener 'click', -> utils.views.settingsPanel.ui.buttons.get.click parent
    @getButton.setAttribute('tabindex', '2')
    @getButton.setAttribute('disabled', 'true')
    urlSpan.appendChild(@getButton)

    # Create the spinner for the get info button
    @getSpinner = document.createElement('span')
    @getButtonText = document.createElement('span')
    @getButtonText.textContent = 'Get Info'
    @getButton.appendChild(@getSpinner)
    @getButton.appendChild(@getButtonText)

    # Create the info pane
    infoPanel = document.createElement('div')
    infoPanel.classList.add('info-panel','section-body')
    form.appendChild(infoPanel)

    # Create the info pane title
    infoTitle = document.createElement('h3')
    infoTitle.textContent = 'Field Mapping Info'
    infoTitle.classList.add('info-panel-title')
    infoPanel.appendChild(infoTitle)

    # Create the info pane description
    infoDescription = document.createElement('p')
    infoDescription.textContent = 'As you enter the url, it will be parsed for the necessary fields to sync with Service Now. Please confirm that they are correct before clicking OK (or pressing enter).'
    infoDescription.classList.add('info-panel-description')
    infoPanel.appendChild(infoDescription)

    # Create the info pane description warning about the disabled buttons
    infoDescriptionWarning = document.createElement('em')
    infoDescriptionWarning.textContent = '(The ok button, and the enter key will remain disabled until all required fields are populated).'
    infoDescription.appendChild(document.createElement('br'))
    infoDescription.appendChild(infoDescriptionWarning)

    # Create the instance info div
    instanceDiv = document.createElement('div')
    instanceDiv.classList.add('info-div','control-group')
    infoPanel.appendChild(instanceDiv)

    # Create the instance info control div
    instanceControlDiv = document.createElement('div')
    instanceControlDiv.classList.add('controls','full-width')
    instanceDiv.appendChild(instanceControlDiv)

    # Create the instance info field label
    instanceLabel = document.createElement('label')
    instanceLabel.textContent = 'Instance:'
    instanceLabel.classList.add('info-label','icon','icon-server', 'quarter-width')
    instanceLabel.setAttribute('for','instance-input')
    instanceControlDiv.appendChild(instanceLabel)

    # Create the instance info input span
    instanceSpan = document.createElement('span')
    instanceControlDiv.appendChild(instanceSpan)

    # Create the instance info field
    @instanceInput = document.createElement('atom-text-editor')
    @instanceInput.classList.add('input', 'instance-input','full-width')
    @instanceInput.setAttribute('id', 'instance-input')
    @instanceInput.setAttribute('type', 'text')
    @instanceInput.setAttribute('mini', 'true')
    @instanceInput.setAttribute('tabindex', '3')
    @instanceInput.setAttribute('placeholder-text', 'Instance Name...')
    @instanceInputModel = @instanceInput.getModel()
    instanceSpan.appendChild(@instanceInput)

    # Create the table info div
    tableNameDiv = document.createElement('div')
    tableNameDiv.classList.add('info-div','control-group')
    infoPanel.appendChild(tableNameDiv)

    # Create the table info control div
    tableNameControlDiv = document.createElement('div')
    tableNameControlDiv.classList.add('controls','full-width')
    tableNameDiv.appendChild(tableNameControlDiv)

    # Create the table name info field label
    tableNameLabel = document.createElement('label')
    tableNameLabel.textContent = 'Table:'
    tableNameLabel.classList.add('info-label','icon','icon-database')
    tableNameLabel.setAttribute('for','table-name-info')
    tableNameControlDiv.appendChild(tableNameLabel)

    # Create the table info input span
    tableNameSpan = document.createElement('span')
    tableNameControlDiv.appendChild(tableNameSpan)

    # Create the target field select element
    @tableNameSelect = document.createElement('select')
    @tableNameSelect.classList.add('form-control','table-name-select')
    @tableNameSelect.setAttribute('id', 'table-name-info')
    @tableNameSelect.setAttribute('tabindex', '4')
    tableNameSpan.appendChild(@tableNameSelect)

    placeholder = document.createElement('option')
    placeholder.setAttribute('disabled', 'true')
    placeholder.setAttribute('selected', 'true')
    placeholder.setAttribute('value', 'placeholder')
    placeholder.textContent = 'Select the table for this file...'
    @tableNameSelect.appendChild(placeholder)

    for table, fields of @tableConfig
      option = document.createElement('option')
      option.setAttribute('value', table)
      option.textContent = table
      @tableNameSelect.appendChild(option)

    # Create the field info div
    targetDiv = document.createElement('div')
    targetDiv.classList.add('info-div','control-group')
    infoPanel.appendChild(targetDiv)

    # Create the field info control div
    targetControlDiv = document.createElement('div')
    targetControlDiv.classList.add('controls','full-width')
    targetDiv.appendChild(targetControlDiv)

    # Create the target info field label
    targetLabel = document.createElement('label')
    targetLabel.textContent = 'Field:'
    targetLabel.classList.add('info-label','icon','icon-gist')
    targetLabel.setAttribute('for','target-info')
    targetControlDiv.appendChild(targetLabel)

    # Create the field info input span
    targetSpan = document.createElement('span')
    targetControlDiv.appendChild(targetSpan)

    # Create the target field select element
    @targetFieldSelect = document.createElement('select')
    @targetFieldSelect.classList.add('form-control')
    @targetFieldSelect.setAttribute('id', 'target-field')
    @targetFieldSelect.setAttribute('tabindex', '5')
    targetSpan.appendChild(@targetFieldSelect)

    # Create the sys id info div
    sysIdDiv = document.createElement('div')
    sysIdDiv.classList.add('info-div','control-group')
    infoPanel.appendChild(sysIdDiv)

    # Create the sys id info control div
    sysIdControlDiv = document.createElement('div')
    sysIdControlDiv.classList.add('controls','full-width')
    sysIdDiv.appendChild(sysIdControlDiv)

    # Create the sys id info field label
    sysIdLabel = document.createElement('label')
    sysIdLabel.textContent = 'Sys Id:'
    sysIdLabel.classList.add('info-label','icon','icon-credit-card')
    sysIdLabel.setAttribute('for','sys-id-info')
    sysIdControlDiv.appendChild(sysIdLabel)

    # Create the sys id info input span
    sysIdSpan = document.createElement('span')
    sysIdControlDiv.appendChild(sysIdSpan)

    # Create the sys id info field
    sysIdInput = document.createElement('atom-text-editor')
    sysIdInput.classList.add('input', 'sys-id-input','full-width')
    sysIdInput.setAttribute('id', 'sys-id-input')
    sysIdInput.setAttribute('type', 'text')
    sysIdInput.setAttribute('mini', 'true')
    sysIdInput.setAttribute('tabindex', '6')
    sysIdInput.setAttribute('placeholder-text', 'Sys ID...')
    @sysIdInputModel = sysIdInput.getModel()
    sysIdSpan.appendChild(sysIdInput)

    # Create the record name info div
    recordNameDiv = document.createElement('div')
    recordNameDiv.classList.add('info-div','control-group')
    infoPanel.appendChild(recordNameDiv)

    # Create the record name info control div
    recordNameControlDiv = document.createElement('div')
    recordNameControlDiv.classList.add('controls','full-width')
    recordNameDiv.appendChild(recordNameControlDiv)

    # Create the record name info field label
    recordNameLabel = document.createElement('label')
    recordNameLabel.textContent = 'Name:'
    recordNameLabel.classList.add('info-label','icon','icon-comment')
    recordNameLabel.setAttribute('for','record-name-info')
    recordNameControlDiv.appendChild(recordNameLabel)

    # Create the record name info input span
    recordNameSpan = document.createElement('span')
    recordNameControlDiv.appendChild(recordNameSpan)

    # Create the record name info field
    recordNameInput = document.createElement('atom-text-editor')
    recordNameInput.classList.add('input', 'record-name-input','full-width')
    recordNameInput.setAttribute('id', 'record-name-input')
    recordNameInput.setAttribute('type', 'text')
    recordNameInput.setAttribute('mini', 'true')
    recordNameInput.setAttribute('tabindex', '7')
    recordNameInput.setAttribute('placeholder-text', 'Record Name...')
    @recordNameInputModel = recordNameInput.getModel()
    recordNameSpan.appendChild(recordNameInput)

    # Create the record description info div
    recordDescriptionDiv = document.createElement('div')
    recordDescriptionDiv.classList.add('info-div','control-group')
    infoPanel.appendChild(recordDescriptionDiv)

    # Create the record description info control div
    recordDescriptionControlDiv = document.createElement('div')
    recordDescriptionControlDiv.classList.add('controls','full-width')
    recordDescriptionDiv.appendChild(recordDescriptionControlDiv)

    # Create the record description info field label
    recordDescriptionLabel = document.createElement('label')
    recordDescriptionLabel.textContent = 'Desc:'
    recordDescriptionLabel.classList.add('info-label','icon','icon-book')
    recordDescriptionLabel.setAttribute('for','record-description-info')
    recordDescriptionControlDiv.appendChild(recordDescriptionLabel)

    # Create the record description info input span
    recordDescriptionSpan = document.createElement('span')
    recordDescriptionControlDiv.appendChild(recordDescriptionSpan)

    # Create the record description info field
    recordDescriptionInput = document.createElement('atom-text-editor')
    recordDescriptionInput.classList.add('input', 'record-description-input','full-width')
    recordDescriptionInput.setAttribute('id', 'record-description-input')
    recordDescriptionInput.setAttribute('type', 'text')
    recordDescriptionInput.setAttribute('mini', 'true')
    recordDescriptionInput.setAttribute('tabindex', '8')
    recordDescriptionInput.setAttribute('placeholder-text', 'Record Description...')
    @recordDescriptionInputModel = recordDescriptionInput.getModel()
    recordDescriptionSpan.appendChild(recordDescriptionInput)

    # Create the sync enabled info div
    syncEnabledDiv = document.createElement('div')
    syncEnabledDiv.classList.add('info-div','control-group')
    infoPanel.appendChild(syncEnabledDiv)

    # Create the sync enabled info control div
    syncEnabledControlDiv = document.createElement('div')
    syncEnabledControlDiv.classList.add('controls','sync-enabled-div','full-width')
    syncEnabledDiv.appendChild(syncEnabledControlDiv)

    # Create the sync enabled info field label
    syncEnabledLabel = document.createElement('label')
    syncEnabledLabel.textContent = 'Enable ServiceNow Sync for this file:'
    syncEnabledLabel.classList.add('sync-enabled-input-label','info-label','icon','icon-sync')
    syncEnabledLabel.setAttribute('for','sync-enabled-input')
    syncEnabledControlDiv.appendChild(syncEnabledLabel)

    # Create the record description info input span
    syncEnabledSpan = document.createElement('span')
    syncEnabledControlDiv.appendChild(syncEnabledSpan)

    # Create the record description info field
    @syncEnabledInput = document.createElement('input')
    @syncEnabledInput.classList.add('input', 'sync-enabled-input')
    @syncEnabledInput.setAttribute('id', 'sync-enabled-input')
    @syncEnabledInput.setAttribute('type', 'checkbox')
    @syncEnabledInput.setAttribute('checked', 'true')
    @syncEnabledInput.setAttribute('tabindex', '9')
    syncEnabledSpan.appendChild(@syncEnabledInput)

    credsPanel = document.createElement('div')
    credsPanel.classList.add('creds-panel','section-body')
    form.appendChild(credsPanel)
    credsTitle = document.createElement('h3')
    credsTitle.textContent = 'Service Now Credentials'
    credsTitle.classList.add('creds-panel-title')
    credsPanel.appendChild(credsTitle)

    credsDescription = document.createElement('p')
    credsDescription.textContent = 'Enter your Service Now instance credentials.'
    credsDescription.classList.add('creds-panel-description')
    credsDescriptionWarning = document.createElement('em')
    credsDescriptionWarning.textContent = '(These will be stored in the same snsync file as the settings in the Field Mapping Info above, and a .gitignore file added. Your password will also be stored in an encrypted format).'
    credsDescription.appendChild(document.createElement('br'))
    credsDescription.appendChild(credsDescriptionWarning)
    credsPanel.appendChild(credsDescription)

    # Create the username div
    usernameDiv = document.createElement('div')
    usernameDiv.classList.add('info-div','control-group')
    credsPanel.appendChild(usernameDiv)

    # Create the username control div
    usernameControlDiv = document.createElement('div')
    usernameControlDiv.classList.add('controls','full-width')
    usernameDiv.appendChild(usernameControlDiv)

    # Create the username field label
    usernameLabel = document.createElement('label')
    usernameLabel.textContent = 'Username:'
    usernameLabel.classList.add('info-label','icon','icon-person')
    usernameLabel.setAttribute('for','username-info')
    usernameControlDiv.appendChild(usernameLabel)

    # Create the username input span
    usernameSpan = document.createElement('span')
    usernameControlDiv.appendChild(usernameSpan)

    # Create the username field
    usernameInput = document.createElement('atom-text-editor')
    usernameInput.classList.add('input', 'username-input','full-width')
    usernameInput.setAttribute('id', 'username-input')
    usernameInput.setAttribute('type', 'text')
    usernameInput.setAttribute('mini', 'true')
    usernameInput.setAttribute('tabindex', '10')
    usernameInput.setAttribute('placeholder-text', 'Your service now username...')
    @usernameInputModel = usernameInput.getModel()
    usernameSpan.appendChild(usernameInput)

    # Create the password div
    passwordDiv = document.createElement('div')
    passwordDiv.classList.add('info-div','control-group')
    credsPanel.appendChild(passwordDiv)

    # Create the password control div
    passwordControlDiv = document.createElement('div')
    passwordControlDiv.classList.add('controls','full-width')
    passwordDiv.appendChild(passwordControlDiv)

    # Create the password field label
    passwordLabel = document.createElement('label')
    passwordLabel.textContent = 'Password:'
    passwordLabel.classList.add('info-label','icon','icon-lock')
    passwordLabel.setAttribute('for','password-info')
    passwordControlDiv.appendChild(passwordLabel)

    # Create the password input span
    passwordSpan = document.createElement('span')
    passwordControlDiv.appendChild(passwordSpan)

    # Create the password field
    @passwordInput = document.createElement('atom-text-editor')
    @passwordInput.classList.add('input', 'password-input','full-width')
    @passwordInput.setAttribute('id', 'password-input')
    @passwordInput.setAttribute('type', 'text')
    @passwordInput.setAttribute('mini', 'true')
    @passwordInput.setAttribute('tabindex', '11')
    @passwordInput.setAttribute('placeholder-text', 'Your service now password...')
    @passwordInputModel = @passwordInput.getModel()
    passwordSpan.appendChild(@passwordInput)

    # Create the button div
    buttonsDiv = document.createElement('div')
    buttonsDiv.classList.add('buttons-div','control-group')
    form.appendChild(buttonsDiv)

    # Create the button control div
    buttonsControlDiv = document.createElement('div')
    buttonsControlDiv.classList.add('buttons-div','controls','align-right')
    buttonsDiv.appendChild(buttonsControlDiv)

    # Create the pull button
    @pullButton = document.createElement('button')
    @pullButton.classList.add('form-control','btn','btn-pull','icon','icon-cloud-download')
    @pullButton.addEventListener 'click', -> utils.views.settingsPanel.ui.buttons.pull.click parent
    @pullButton.setAttribute('disabled', 'true')
    @pullButton.setAttribute('tabindex', '12')
    @pullButton.textContent = 'Retrieve'
    buttonsControlDiv.appendChild(@pullButton)

    # Create the OK button
    @okButton = document.createElement('button')
    @okButton.classList.add('form-control','btn','btn-ok','icon','icon-check')
    @okButton.addEventListener 'click', -> utils.views.settingsPanel.ui.buttons.ok.click parent
    @okButton.setAttribute('disabled', 'true')
    @okButton.setAttribute('tabindex', '13')
    @okButton.textContent = 'OK'
    buttonsControlDiv.appendChild(@okButton)

    # Create the cancel button
    cancelButton = document.createElement('button')
    cancelButton.classList.add('form-control','btn','btn-cancel','icon','icon-circle-slash')
    cancelButton.textContent = 'Cancel'
    cancelButton.setAttribute('tabindex', '14')
    cancelButton.addEventListener 'click', -> utils.views.settingsPanel.ui.buttons.cancel.click parent
    buttonsControlDiv.appendChild(cancelButton)

    # Wire up actions for form fields and controls
    @urlInputModel.onDidChange( ->
      utils.views.settingsPanel.actions.updateElements parent
    )

    @instanceInputModel.onDidChange( ->
      utils.views.settingsPanel.actions.getInstanceValue parent
    )

    @tableNameSelect.addEventListener('change', (value) ->
      utils.views.settingsPanel.actions.updateFieldSelect @value, parent
    )

    @targetFieldSelect.addEventListener('change', (value) ->
      utils.views.settingsPanel.actions.getFieldValue @value, parent
    )

    @sysIdInputModel.onDidChange( ->
      utils.views.settingsPanel.actions.getSysIdValue parent
    )

    @recordNameInputModel.onDidChange( ->
      utils.views.settingsPanel.actions.getRecordNameValue parent
    )

    @recordDescriptionInputModel.onDidChange( ->
      utils.views.settingsPanel.actions.getRecordDescriptionValue parent
    )

    @syncEnabledInput.addEventListener('change', (value) ->
      utils.views.settingsPanel.actions.toggleSyncEnabled parent
    )

    @usernameInputModel.onDidChange( ->
      utils.views.settingsPanel.actions.handleUsername parent
    )

    @passwordInputModel.onDidChange( ->
      utils.views.settingsPanel.actions.handlePassword parent
    )

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  getElement: ->
    @element
