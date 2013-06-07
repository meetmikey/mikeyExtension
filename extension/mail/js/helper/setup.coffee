class Setup
  inboxSelector: MeetMikey.Constants.Selectors.inboxContainer
  tabsSelector: MeetMikey.Constants.Selectors.tabsContainer
  userEmailSelector: MeetMikey.Constants.Selectors.userEmail
  inInbox: MeetMikey.Helper.Url.inInbox

  logger: MeetMikey.Helper.Logger
  hasLoggedIn : false

  start: =>
    $(window).one('DOMSubtreeModified', @bootstrap)

  bootstrap: =>
    MeetMikey.Helper.BetaAccess.checkAccess @waitAndStartAuthFlow
    MeetMikey.Globals.checkTabsInterval = null

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
    if !@hasLoggedIn
      MeetMikey.Helper.Analytics.trackEvent 'login'
      @hasLoggedIn = true

  initalizeGlobalUser: (data) =>
    MeetMikey.globalUser = new MeetMikey.Model.User data
    MeetMikey.Helper.Analytics.setUser MeetMikey.globalUser
    @dropdownView.rerender()
    if MeetMikey.globalUser.checkInvalidToken()
      @injectReauthModal()
    MeetMikey.globalUser.checkOnboard()

  checkMultipleInbox: (callback) =>
    controlSelector = MeetMikey.Constants.Selectors.inboxControlsContainer
    tabContainerSelector = MeetMikey.Constants.Selectors.multipleInboxTabsContainer
    MeetMikey.Helper.DOMManager.waitAndFind controlSelector, (target) =>
      margin = target.css 'margin-left'
      controlSelectorArray = $(tabContainerSelector).find(controlSelector)
      
      count = 0
      if controlSelectorArray && controlSelectorArray.length
        nonDispNone = _.filter controlSelectorArray, (element) -> $(element).css('display') != "none"
        count = nonDispNone.length

      # move 400px into named constant
      MeetMikey.Globals.multipleInbox = @multipleInbox = margin isnt "-400px" and count == 0
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
  injectOnboardModal: (errMsg) =>
    $('body').append $('<div id="mm-onboard-modal"></div>')
    view = new MeetMikey.View.OnboardModal el: '#mm-onboard-modal', model: new MeetMikey.Model.OnboardModal ({errMsg : errMsg})
    view.render()
    view.on 'disabled', => @dropdownView.rerender()
    view.on 'authorized', (userData) =>
      @authorized(userData)
      @injectThanksModal() if MeetMikey.globalUser.get('onboarding')
    view.on 'emailMismatch', (error) =>
      view.remove()
      @injectOnboardModal (error)

  # ReAuth modal
  injectReauthModal: (errMsg) =>
    $('body').append $('<div id="mm-reauth-modal"></div>')
    view = new MeetMikey.View.ReAuthModal el: '#mm-reauth-modal', model: new MeetMikey.Model.ReAuthModal ({errMsg : errMsg})
    view.render()
    view.on 'disabled', => @dropdownView.rerender()
    view.on 'deleted', =>  @injectFeedbackModal()
    #TODO: inject some thanks modal on auth here... (but not the thanksModal above)
    view.on 'authorized', (userData) =>
      @authorized(userData)
    view.on 'emailMismatch', (error) =>
      view.remove()
      @injectReauthModal (error)

  injectThanksModal: =>
    $('body').append $('<div id="mm-thanks-modal"></div>')
    view = new MeetMikey.View.ThanksModal el: '#mm-thanks-modal'
    view.render()

  injectFeedbackModal: =>
    $('body').append $('<div id="mm-feedback-modal"></div>')
    view = new MeetMikey.View.FeedbackModal el: '#mm-feedback-modal'
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
    if ! MeetMikey.Globals.checkTabsInterval
      MeetMikey.Globals.checkTabsInterval = setInterval @checkForMissingTabs, 5*1000

  checkForMissingTabs: =>
    if @inInbox()
      numContainers = $('#mm-tabs-container, #mm-container').length
      #if ( numContainers > 2 )
        #@logger.info 'too many containers: ', numContainers
      if ! ( numContainers >= 2 )
        @logger.info 'tabs are missing, reloading view'
        MeetMikey.Helper.Analytics.trackEvent 'missingTabs'
        @reloadView()

  reloadView: =>
    @mainView?._teardown()
    MeetMikey.Helper.clearCheckTabsInterval()
    @bootstrap()

MeetMikey.Helper.Setup = new Setup()
