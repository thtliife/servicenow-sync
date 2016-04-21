{CompositeDisposable} = require 'atom'

module.exports =
class ServicenowSyncProgress
  progressTextContent: ''

  constructor: (serializedState, parent) ->
    # @subscriptions = new CompositeDisposable

    # region Build the modal panel

    # region Create root element
    @element = document.createElement('div')
    @element.classList.add('servicenow-sync')
    # endregion Create root element

    # region Create the progress bar
    progressDiv = document.createElement('div')
    progressDiv.classList.add('block')
    progressSpinner = document.createElement('div')
    progressSpinner.classList.add('inline-block','spinner', 'progress-spinner')
    @progressText = document.createElement('span')
    @progressText.classList.add('inline-block')
    @progressText.textContent = @progressTextContent

    progressDiv.appendChild(progressSpinner)
    progressDiv.appendChild(@progressText)
    @element.appendChild(progressDiv)

    # endregion Create the progress bar

    # endregion Build the modal panel


  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  getElement: ()->
    @element

  getProgressText: ->
    # @element
    @progressText.textContent

  setProgressText: (text) ->
    @progressText.textContent = text
