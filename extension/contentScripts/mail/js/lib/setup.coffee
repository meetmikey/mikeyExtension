class Setup
  inboxSelector: MeetMikey.Settings.Selectors.inboxContainer
  tabsSelector: MeetMikey.Settings.Selectors.tabsContainer
  userEmailSelector: MeetMikey.Settings.Selectors.userEmail

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
    @checkMultipleInbox =>
      @initalizeGlobalUser userData
      @trackLoginEvent(userData)
      @waitForInbox()

  trackLoginEvent: (user) =>
    MeetMikey.Helper.Mixpanel.trackEvent 'login', user

  initalizeGlobalUser: (data) =>
    MeetMikey.globalUser = new MeetMikey.Model.User data
    MeetMikey.Helper.Mixpanel.setUser MeetMikey.globalUser
    MeetMikey.globalUser.checkOnboard()

  checkMultipleInbox: (callback) =>
    selector = MeetMikey.Settings.Selectors.inboxControlsContainer
    MeetMikey.Helper.DOMManager.waitAndFind selector, (target) =>
      margin = target.css 'margin-left'
      MeetMikey.Globals.multipleInbox = @multipleInbox = margin isnt "-400px"
      @setSelectors()
      callback @multipleInbox

  setSelectors: =>
    selectors = MeetMikey.Settings.Selectors
    if @multipleInbox
      @inboxSelector = selectors.multipleInboxContainer
      @tabsSelector = selectors.multipleInboxTabsContianer
      $('body').addClass 'multiple-inbox'
    else
      @inboxSelector = selectors.inboxContainer
      @tabsSelector = selectors.tabsContainer

  waitForInbox: =>
    inboxFound = @checkIfInInbox()
    $(window).on 'hashchange', @checkIfInInbox unless inboxFound

  isInInbox: =>
    hash = window.location.hash
    hash is '' or /#(?:inbox)?$/.test hash

  checkIfInInbox: =>
    inInbox = @isInInbox()
    if inInbox
      $(window).off 'hashchange', @checkIfInInbox
      MeetMikey.Helper.DOMManager.waitAndFindAll @inboxSelector, @tabsSelector, @checkAndInjectMainView
    inInbox

  injectDropdown: =>
    return if @dropdownView?
    @dropdownView = new MeetMikey.View.Dropdown
      el: MeetMikey.Settings.Selectors.navBar, append: true
    @dropdownView.render()

  injectOnboardModal: =>
    $('body').append $('<div id="mm-onboard-modal"></div>')
    view = new MeetMikey.View.OnboardModal el: '#mm-onboard-modal'
    view.render()
    view.on 'authorized', (userData) =>
      @injectWelcomeModal()
      @authorized(userData)

  injectWelcomeModal: =>
    $('body').append $('<div id="mm-welcome-modal"></div>')
    view = new MeetMikey.View.WelcomeModal el: '#mm-welcome-modal'
    view.render()

  injectMainView: =>
    @mainView = new MeetMikey.View.Main el: 'body', owned: false, multipleInbox: @multipleInbox
    @mainView.render()

  checkAndInjectMainView: =>
    if @isInInbox()
      @injectMainView()
    else
      @waitForInbox()


MeetMikey.Helper.Setup = new Setup()
