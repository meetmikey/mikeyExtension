class Setup
  inboxSelector: MeetMikey.Constants.Selectors.inboxContainer
  tabsSelector: MeetMikey.Constants.Selectors.tabsContainer
  userEmailSelector: MeetMikey.Constants.Selectors.userEmail

  logger: MeetMikey.Helper.Logger
  checkTabsInterval: null

  start: =>
    $(window).one('DOMSubtreeModified', @bootstrap)

  bootstrap: =>
    MeetMikey.Helper.BetaAccess.checkAccess @waitAndStartAuthFlow

  waitAndStartAuthFlow: =>
    MeetMikey.Helper.findSelectors @userEmailSelector, @startAuthFlow

  startAuthFlow: (target) =>
    @injectDropdown()
    MeetMikey.Helper.OAuth.checkUser (userData) =>
      if userData?
        @authorized(userData)
      else
        @injectOnboardModal()

  authorized: (userData) =>
    @checkPreviewPane()
    @checkMultipleInbox =>
      @initalizeGlobalUser userData
      @trackLoginEvent(userData)
      @waitForInbox()

  trackLoginEvent: (user) =>
    MeetMikey.Helper.Analytics.trackEvent 'login'

  initalizeGlobalUser: (data) =>
    MeetMikey.globalUser = new MeetMikey.Model.User data
    MeetMikey.Helper.Analytics.setUser MeetMikey.globalUser
    MeetMikey.globalUser.checkOnboard()

  checkMultipleInbox: (callback) =>
    controlSelector = MeetMikey.Constants.Selectors.inboxControlsContainer
    tabContainerSelector = MeetMikey.Constants.Selectors.multipleInboxTabsContainer
    MeetMikey.Helper.DOMManager.waitAndFind controlSelector, (target) =>
      margin = target.css 'margin-left'
      # move 400px into named constant
      MeetMikey.Globals.multipleInbox = @multipleInbox = margin isnt "-400px" and $(tabContainerSelector).find(controlSelector)?.length == 0
      @setSelectors()
      callback @multipleInbox

  checkPreviewPane: (callback) =>
    previewPaneSelector = MeetMikey.Constants.Selectors.previewPaneSelector
    if $(previewPaneSelector) && $(previewPaneSelector).length
      MeetMikey.Globals.previewPane = true
      $('body').addClass('preview-pane')
    else
      $('body').removeClass('preview-pane')
      MeetMikey.Globals.previewPane = false

  setSelectors: =>
    selectors = MeetMikey.Constants.Selectors
    if @multipleInbox
      @inboxSelector = selectors.multipleInboxContainer
      @tabsSelector = selectors.multipleInboxTabsContainer
      $('body').addClass 'multiple-inbox'
    else
      @inboxSelector = selectors.inboxContainer
      @tabsSelector = selectors.tabsContainer

  waitForInbox: =>
    inboxFound = @checkIfInInbox()
    $(window).on 'hashchange', @checkIfInInbox unless inboxFound

  inInbox: MeetMikey.Helper.Url.inInbox

  checkIfInInbox: =>
    inInbox = @inInbox()
    if inInbox
      $(window).off 'hashchange', @checkIfInInbox
      MeetMikey.Helper.DOMManager.waitAndFindAll @inboxSelector, @tabsSelector, @checkAndInjectMainView
    inInbox

  injectDropdown: =>
    return if @dropdownView?
    @dropdownView = new MeetMikey.View.Dropdown
      el: MeetMikey.Constants.Selectors.navBar, append: true
    @dropdownView.render()

  # Rename Auth modal
  injectOnboardModal: =>
    $('body').append $('<div id="mm-onboard-modal"></div>')
    view = new MeetMikey.View.OnboardModal el: '#mm-onboard-modal'
    view.render()
    view.on 'disabled', => @dropdownView.rerender()
    view.on 'authorized', (userData) =>
      @authorized(userData)
      @injectThanksModal() if MeetMikey.globalUser.get('onboarding')

  # Rename Welcome Modal
  injectThanksModal: =>
    $('body').append $('<div id="mm-thanks-modal"></div>')
    view = new MeetMikey.View.ThanksModal el: '#mm-thanks-modal'
    view.render()

  injectMainView: =>
    @mainView = new MeetMikey.View.Main el: 'body', owned: false, multipleInbox: @multipleInbox
    @mainView.render()
    @pollForMissingTabs()

  checkAndInjectMainView: =>
    if @inInbox()
      @injectMainView()
    else
      @waitForInbox()

  pollForMissingTabs: =>
    if ! @checkTabsInterval
      @checkTabsInterval = setInterval @checkForMissingTabs, 5*1000

  checkForMissingTabs: =>
    #console.log "checking for tabs..."
    if ! ( $('#mm-tabs-container, #mm-container').length == 2 )
      @logger.info 'tabs are missing, reloading view'
      @reloadView()

  reloadView: =>
    @mainView?._teardown()
    @bootstrap()


MeetMikey.Helper.Setup = new Setup()
