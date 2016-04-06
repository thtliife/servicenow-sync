{CompositeDisposable} = require 'atom'
module.exports =
class ServicenowSyncView
  constructor: (serializedState) ->
    # region Required vars
    url = null
    fieldTypes =
      sys_ui_page: [
        { field: 'html', displayName: 'HTML' }
        { field: 'client_script', displayName: 'Client Script'}
        { field: 'processing_script', displayName: 'Processing Script'}
      ]
      sys_ui_macro: [
        { field: 'xml', displayName: 'XML' }
      ]
      sys_ui_script: [
        { field: 'script', displayName: 'Script' }
      ]
      sys_script_include: [
        { field: 'script', displayName: 'Script' }
      ]
      content_css: [
        { field: 'style', displayName: 'Style' }
      ]
      content_block_programmatic: [
        { field: 'programmatic_content', displayName: 'Dynamic content' }
      ]
      content_block_detail: [
        { field: 'condition', displayName: 'Condition' }
      ]
      content_type: [
        { field: 'detail', displayName: 'Detail Template' }
        { field: 'summary', displayName: 'Summary Template'}
      ]
      catalog_script_client: [
        { field: 'script', displayName: 'Script' }
      ]
      sys_ui_message: [
        { field: 'message', displayName: 'Message' }
      ]
      sysevent_script_action: [
        { field: 'script', displayName: 'Script' }
      ]
      sys_script_client: [
        { field: 'script', displayName: 'Script' }
      ]
      sys_script_validator: [
        { field: 'validator', displayName: 'Validator' }
      ]
      sys_processor: [
        { field: 'script', displayName: 'Script' }
      ]
    validElements =
      instance: false
      tableName: false
      sysId: false
      target: false
      username: false
      password: false

    # endregion Required vars

    # region Required functions
    isValid = ->
      setTrue = true
      setTrue = false if validElements.instance is false
      setTrue = false if validElements.tableName is false
      setTrue = false if validElements.sysId is false
      setTrue = false if validElements.target is false
      setTrue = false if validElements.username is false
      setTrue = false if validElements.password is false
      setTrue

    parseUrlInput = ->
      url = urlInputModel.buffer.lines[0]
      instanceName = url.split('://')[1]?.split('.')[0]
      tableName = url.split('://')[1]?.replace('/nav_to.do?uri=','/').split('service-now.com/')[1]?.split('.')[0]
      sysId = url.split('://')[1]?.split('sys_id=')[1]?.split('&')[0]
      hideCreds = false;

      try
        availableTargetFields = fieldTypes[tableName]
      catch
        avaliableTargetFields = null

      if instanceName
        if instanceName.length < 1
          instanceInfoDiv.classList.add('hidden')
          hideCreds = true
          validElements.instance = false
        else
          instanceInfoDiv.classList.remove('hidden')
          validElements.instance = true
      else
        instanceInfoDiv.classList.add('hidden')
        hideCreds = true
        validElements.instance = false

      if tableName
        if tableName.length < 1
          tableNameInfoDiv.classList.add('hidden')
          hideCreds = true
          validElements.tableName = false
        else
          tableNameInfoDiv.classList.remove('hidden')
          validElements.tableName = true
      else
        tableNameInfoDiv.classList.add('hidden')
        hideCreds = true
        validElements.tableName = false

      if sysId
        if sysId.length < 1
          sysIdInfoDiv.classList.add('hidden')
          hideCreds = true
          validElements.sysId = false
        else
          sysIdInfoDiv.classList.remove('hidden')
          validElements.sysId = true

      else
        sysIdInfoDiv.classList.add('hidden')
        hideCreds = true
        validElements.sysId = false

      if availableTargetFields
        if availableTargetFields.length < 1
          targetInfoSelect.removeChild(targetInfoSelect.firstChild) while targetInfoSelect.firstChild
          targetInfoDiv.classList.add('hidden')
          hideCreds = true
          validElements.target = false
        else
          targetInfoSelect.removeChild(targetInfoSelect.firstChild) while targetInfoSelect.firstChild
          # addOption targetField.field, targetField.displayName, targetInfoSelect for targetField in availableTargetFields
          ((val, txt, slct) ->
            option = document.createElement('option')
            option.text = txt
            option.value = val
            slct.appendChild(option)) targetField.field, targetField.displayName, targetInfoSelect for targetField in availableTargetFields
          targetInfoDiv.classList.remove('hidden')
          validElements.target = true
      else
        targetInfoSelect.removeChild(targetInfoSelect.firstChild) while targetInfoSelect.firstChild
        targetInfoDiv.classList.add('hidden')
        hideCreds = true
        validElements.target = false


      if hideCreds then credsPanel.classList.add('hidden') else credsPanel.classList.remove('hidden')
      if isValid()
        okButton.removeAttribute('disabled')
        okButton.classList.remove('disabled')
      else
        okButton.setAttribute('disabled', 'true')
        okButton.classList.add('disabled')

      instanceInfo.textContent = instanceName
      tableNameInfo.textContent = tableName
      sysIdInfo.textContent = sysId

    maskPassword = ->
      pwCount = passwordInputModel.buffer.lines[0].length
      passwordInput.classList.add('occlude') if pwCount > 0
      passwordInput.classList.remove('occlude') if pwCount < 1

    parseUsername = ->
      # alert(usernameInputModel.buffer.lines[0] + ' | ' + usernameInputModel.buffer.lines[0].length)
      if usernameInputModel.buffer.lines[0].length < 1
        validElements.username = false
      else
        validElements.username = true

      if isValid()
        okButton.removeAttribute('disabled')
        okButton.classList.remove('disabled')
      else
        okButton.setAttribute('disabled', 'true')
        okButton.classList.add('disabled')

    parsePassword = ->
      if passwordInputModel.buffer.lines[0].length < 1
        validElements.password = false
      else
        validElements.password = true

      if isValid()
        okButton.removeAttribute('disabled')
        okButton.classList.remove('disabled')
      else
        okButton.setAttribute('disabled', 'true')
        okButton.classList.add('disabled')

    #  endregion Required functions

    # region Build the modal panel

    # region Create root element
    @element = document.createElement('div')
    @element.classList.add('servicenow-sync')
    # endregion Create root element

    # region Create the title
    title = document.createElement('h2')
    title.classList.add('centred')
    title.textContent = 'Configure this file for Service Now Sync'
    # endregion Create the title

    # region Create the main form element
    form = document.createElement('div')
    # endregion Create the main form element

    # region Create the label for the url input
    urlLabel = document.createElement('label')
    urlLabel.textContent = 'Enter a service now URL here:'
    urlLabel.classList.add('url-label','icon','icon-globe')
    urlLabel.setAttribute('for','url-input')
    # endregion Create the label for the url input

    # region Create the url input
    urlInput = document.createElement('atom-text-editor')
    urlInput.classList.add('url-input')
    urlInput.setAttribute('id', 'url-input')
    urlInput.setAttribute('type', 'text')
    urlInput.setAttribute('mini', 'true')
    urlInput.setAttribute('placeholder-text', 'https://instancename.service-now.com/nav_to.do...')
    # endregion Create the url input

    # region Create the info pane
    infoPanel = document.createElement('div')
    infoPanel.classList.add('info-panel','section-body')
    # endregion Create the info pane

    # region Create the info pane title
    infoTitle = document.createElement('h3')
    infoTitle.textContent = 'Field Mapping Info'
    infoTitle.classList.add('info-panel-title')
    # endregion Create the info pane title

    # region Create the info pane description
    infoDescription = document.createElement('p')
    infoDescription.textContent = 'As you enter the url, it will be parsed for the necessary fields to sync with Service Now. Please confirm that they are correct before clicking OK (or pressing enter).'
    infoDescription.classList.add('info-panel-description')
    infoDescriptionWarning = document.createElement('em')
    infoDescriptionWarning.textContent = '(The ok button, and the enter key will remain disabled until all required fields are populated).'
    infoDescription.appendChild(document.createElement('br'))
    infoDescription.appendChild(infoDescriptionWarning)
    # endregion Create the info pane description

    # region Create the creds pane
    credsPanel = document.createElement('div')
    credsPanel.classList.add('creds-panel', 'section-body', 'hidden')
    # endregion Create the creds pane

    # region Create the creds pane title
    credsTitle = document.createElement('h3')
    credsTitle.textContent = 'Service Now Credentials'
    credsTitle.classList.add('creds-panel-title')
    # endregion Create the info pane title

    # region Create the info pane description
    credsDescription = document.createElement('p')
    credsDescription.textContent = 'Enter your Service Now instance credentials.'
    credsDescription.classList.add('creds-panel-description')
    credsDescriptionWarning = document.createElement('em')
    credsDescriptionWarning.textContent = '(These will be stored in the same snsync file as the settings in the Field Mapping Info above, and a .gitignore file added. Your password will also be stored in an encrypted format).'
    credsDescription.appendChild(document.createElement('br'))
    credsDescription.appendChild(credsDescriptionWarning)
    # endregion Create the info pane description

    # region Create the control groups for the info panel
    # Create the instance info div
    instanceInfoDiv = document.createElement('div')
    instanceInfoDiv.classList.add('info-div','control-group','hidden')

    # Create the table name info div
    tableNameInfoDiv = document.createElement('div')
    tableNameInfoDiv.classList.add('info-div','control-group','hidden')

    # Create the sys id info div
    sysIdInfoDiv = document.createElement('div')
    sysIdInfoDiv.classList.add('info-div','control-group','hidden')

    # Create the target info div
    targetInfoDiv = document.createElement('div')
    targetInfoDiv.classList.add('info-div','control-group','hidden')
    # endregion Create the control groups for the info panel

    # region Create the control groups for the creds panel
    # Create the creds div
    credsDiv = document.createElement('div')
    credsDiv.classList.add('creds-div','control-group')
    # endregion Create the control groups for the creds panel

    # region Create the controls for each control group

    # region Instance info
    # Create the instance info field label
    instanceInfoLabel = document.createElement('label')
    instanceInfoLabel.textContent = 'Instance:'
    instanceInfoLabel.classList.add('info-label','icon','icon-server')
    instanceInfoLabel.setAttribute('for','instance-info')

    # Create the instance info field
    instanceInfo = document.createElement('span')
    instanceInfo.textContent = url
    instanceInfo.setAttribute('id', 'instance-info','info-result')
    # endregion Instance info

    # region Table name info
    # Create the table name info field label
    tableNameInfoLabel = document.createElement('label')
    tableNameInfoLabel.textContent = 'Table Name:'
    tableNameInfoLabel.classList.add('info-label','icon','icon-database')
    tableNameInfoLabel.setAttribute('for','table-name-info')

    # Create the table name info field
    tableNameInfo = document.createElement('span')
    tableNameInfo.textContent = url
    tableNameInfo.setAttribute('id', 'table-name-info','info-result')
    # endregion Table name info

    # region Sys id info
    # Create the sys id info field label
    sysIdInfoLabel = document.createElement('label')
    sysIdInfoLabel.textContent = 'Sys ID:'
    sysIdInfoLabel.classList.add('info-label','icon','icon-credit-card')
    sysIdInfoLabel.setAttribute('for','sys-id-info')

    # Create the sys id info field
    sysIdControlDiv = document.createElement('div')
    sysIdControlDiv.classList.add('controls')

    sysIdInfo = document.createElement('span')
    sysIdInfo.setAttribute('id', 'sys-id-info','info-result')
    # endregion Sys id info

    # region Target field info
    # Create the target field info field
    targetControlDiv = document.createElement('div')
    targetControlDiv.classList.add('controls','full-width')

    # Create the span to hold the label and select element
    targetInfoSpan = document.createElement('span')
    targetInfolabelDiv = document.createElement('div')
    targetInfolabelDiv.classList.add('quarter-width')
    targetInfoSelectDiv = document.createElement('div')
    targetInfoSelectDiv.classList.add('three-quarter-width','info-result')


    # Create the target field info label
    targetInfoLabel = document.createElement('label')
    targetInfoLabel.textContent = 'Target field:'
    targetInfoLabel.classList.add('info-label','icon','icon-gist')
    targetInfoLabel.setAttribute('for','target-info')

    # Create the target field select element
    targetInfoSelect = document.createElement('select')
    targetInfoSelect.classList.add('form-control')
    targetInfoSelect.setAttribute('id', 'target-info')
    # endregion Target field info

    # region Creds controls
    # region Create the username control div
    usernameControlDiv = document.createElement('div')
    usernameControlDiv.classList.add('controls','full-width')
    usernameSpan = document.createElement('span')
    # endregion Create the username control div

    # region Create the password control div
    passwordControlDiv = document.createElement('div')
    passwordControlDiv.classList.add('controls','full-width')
    passwordSpan = document.createElement('span')
    # endregion Create the password control div


    # region Create the label for the username input
    usernameLabel = document.createElement('label')
    usernameLabel.textContent = 'Username:'
    usernameLabel.classList.add('creds-label','icon','icon-person','quarter-width')
    usernameLabel.setAttribute('for','username-input')
    # endregion Create the label for the username input

    # region Create the username input
    usernameInput = document.createElement('atom-text-editor')
    usernameInput.classList.add('username-input','half-width')
    usernameInput.setAttribute('id', 'username-input')
    usernameInput.setAttribute('type', 'text')
    usernameInput.setAttribute('mini', 'true')
    usernameInput.setAttribute('placeholder-text', 'Username...')
    # endregion Create the username input

    # region Create the label for the password input
    passwordLabel = document.createElement('label')
    passwordLabel.textContent = 'Password:'
    passwordLabel.classList.add('creds-label','icon','icon-lock','quarter-width')
    passwordLabel.setAttribute('for','password-input')
    # endregion Create the label for the password input

    # region Create the password input
    passwordInput = document.createElement('atom-text-editor')
    passwordInput.classList.add('password-input','half-width')
    passwordInput.setAttribute('id', 'password-input')
    passwordInput.setAttribute('type', 'text')
    passwordInput.setAttribute('mini', 'true')
    passwordInput.setAttribute('placeholder-text', 'Password...')

    # endregion Create the password input

    # endregion Creds controls

    # region buttons
    # Create the button div
    buttonsDiv = document.createElement('div')
    buttonsDiv.classList.add('buttons-div','control-group')

    buttonsControlDiv = document.createElement('div')
    buttonsControlDiv.classList.add('buttons-div','controls','align-right')

    okButton = document.createElement('button')
    okButton.classList.add('form-control','btn','btn-ok','icon','icon-check')
    okButton.setAttribute('disabled', 'true')
    okButton.textContent = 'OK'

    cancelButton = document.createElement('button')
    cancelButton.classList.add('form-control','btn','btn-cancel','icon','icon-circle-slash')
    cancelButton.textContent = 'Cancel'
    # endregion buttons

    # endregion Create the controls for each control group

    # region Populate the container elements

    # region Populate the instance info div
    instanceInfoDiv.appendChild(instanceInfoLabel)
    instanceInfoDiv.appendChild(instanceInfo)
    # endregion Populate the instance info div

    # region Populate the table name info div
    tableNameInfoDiv.appendChild(tableNameInfoLabel)
    tableNameInfoDiv.appendChild(tableNameInfo)
    # endregion Populate the table name info div

    # region Populate the sys id info div
    sysIdInfoDiv.appendChild(sysIdInfoLabel)
    sysIdInfoDiv.appendChild(sysIdInfo)
    # endregion Populate the sys id info div

    # region Populate the target field info div
    targetInfolabelDiv.appendChild(targetInfoLabel)
    targetInfoSpan.appendChild(targetInfoSelect)
    targetInfoSelectDiv.appendChild(targetInfoSpan)
    targetControlDiv.appendChild(targetInfolabelDiv)
    targetControlDiv.appendChild(targetInfoSelectDiv)
    targetInfoDiv.appendChild(targetControlDiv)
    # endregion Populate the target field info div

    # region Populate the creds div
    usernameSpan.appendChild(usernameInput)
    usernameControlDiv.appendChild(usernameLabel)
    usernameControlDiv.appendChild(usernameSpan)
    passwordSpan.appendChild(passwordInput)
    passwordControlDiv.appendChild(passwordLabel)
    passwordControlDiv.appendChild(passwordSpan)


    credsDiv.appendChild(usernameControlDiv)
    credsDiv.appendChild(passwordControlDiv)
    # endregion Populate the creds div

    # region Populate the buttons div
    buttonsControlDiv.appendChild(okButton)
    buttonsControlDiv.appendChild(cancelButton)
    buttonsDiv.appendChild(buttonsControlDiv)
    # endregion Populate the buttons div

    # region Populate the infoPanel div
    infoPanel.appendChild(infoTitle)
    infoPanel.appendChild(infoDescription)
    infoPanel.appendChild(instanceInfoDiv)
    infoPanel.appendChild(tableNameInfoDiv)
    infoPanel.appendChild(sysIdInfoDiv)
    infoPanel.appendChild(targetInfoDiv)
    # endregion Populate the infoPanel div

    # region Populate the credsPanel div
    credsPanel.appendChild(credsTitle)
    credsPanel.appendChild(credsDescription)
    credsPanel.appendChild(credsDiv)
    # endregion Populate the credsPanel div

    # region Populate the main form
    form.appendChild(title)
    form.appendChild(urlLabel)
    form.appendChild(urlInput)
    form.appendChild(infoPanel)
    form.appendChild(credsPanel)

    form.appendChild(buttonsDiv)
    # endregion Populate the main form

    # endregion Populate the container elements

    # Append the form to the root element
    @element.appendChild(form)

    # endregion Build the modal panel

    # region Convert input URL to vars for CSON
    # Get the reference to the urlInput field
    urlInputModel = urlInput.getModel()

    # Get the reference to the passwordInput field
    usernameInputModel = usernameInput.getModel()

    # Get the reference to the passwordInput field
    passwordInputModel = passwordInput.getModel()
    # passwordInputModel.copy = -> # TODO: Fix copying of password

    parseUrlInput() # TODO: Remove this line

    # Process the inputs on change
    urlInputModel.onDidChange( parseUrlInput )

    usernameInputModel.onDidChange(
      ->
        parseUsername()
    )
    passwordInputModel.onDidChange(
      ->
        maskPassword()
        parsePassword()
    )

    # endregion Convert input URL to vars for CSON

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  getElement: ->
    @element
