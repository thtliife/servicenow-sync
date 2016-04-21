ServicenowSync = require '../lib/servicenow-sync'
utils = require '../lib/modules/servicenow-sync-utils'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "ServicenowSync", ->
  [workspaceElement, activationPromise] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage('servicenow-sync')

  describe "when the servicenow-sync:toggle event is triggered", ->
    it "hides and shows the modal panel", ->
      # Before the activation event the view is not on the DOM, and no panel
      # has been created
      # expect(workspaceElement.querySelector('.servicenow-sync')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.commands.dispatch workspaceElement, 'servicenow-sync:configure-file'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(workspaceElement.querySelector('.servicenow-sync')).toExist()

        servicenowSyncElement = workspaceElement.querySelector('.servicenow-sync')
        expect(servicenowSyncElement).toExist()

        servicenowSyncPanel = atom.workspace.panelForItem(servicenowSyncElement)
        expect(servicenowSyncPanel.isVisible()).toBe false
        atom.commands.dispatch workspaceElement, 'servicenow-sync:toggle'
        expect(servicenowSyncPanel.isVisible()).toBe true

    it "hides and shows the view", ->
      # This test shows you an integration test testing at the view level.

      # Attaching the workspaceElement to the DOM is required to allow the
      # `toBeVisible()` matchers to work. Anything testing visibility or focus
      # requires that the workspaceElement is on the DOM. Tests that attach the
      # workspaceElement to the DOM are generally slower than those off DOM.
      jasmine.attachToDOM(workspaceElement)

      expect(workspaceElement.querySelector('.servicenow-sync')).not.toExist()

      # This is an activation event, triggering it causes the package to be
      # activated.
      atom.commands.dispatch workspaceElement, 'servicenow-sync:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        # Now we can test for view visibility
        servicenowSyncElement = workspaceElement.querySelector('.servicenow-sync')
        expect(servicenowSyncElement).toBeVisible()
        atom.commands.dispatch workspaceElement, 'servicenow-sync:toggle'
        expect(servicenowSyncElement).not.toBeVisible()
