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
    @initalizeGlobalUser userData
    @trackLoginEvent(userData)
    @waitForInbox()

  trackLoginEvent: (user) =>
    MeetMikey.Helper.Mixpanel.trackEvent 'login', user

  initalizeGlobalUser: (data) =>
    MeetMikey.globalUser = new MeetMikey.Model.User data
    MeetMikey.Helper.Mixpanel.setUser MeetMikey.globalUser
    MeetMikey.globalUser.checkOnboard()

  waitForInbox: =>
    @checkIfInInbox()
    $(window).on 'hashchange', @checkIfInInbox

  isInInbox: =>
    hash = window.location.hash
    hash is '' or hash.match /#(?:inbox)?$/

  checkIfInInbox: =>
    if @isInInbox()
      $(window).off 'hashchange', @checkIfInInbox
      MeetMikey.Helper.DOMManager.waitAndFindAll @inboxSelector, @tabsSelector, @checkAndInjectMainView

  injectDropdown: =>
    view = new MeetMikey.View.Dropdown
      el: MeetMikey.Settings.Selectors.navBar, append: true
    view.render()

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

  injectMainView: (target) =>
    target ?= @inboxSelector
    @mainView = new MeetMikey.View.Main el: 'body', inboxTarget: target, owned: false
    @mainView.render()

  checkAndInjectMainView: =>
    if @isInInbox()
      @injectMainView()
    else
      @waitForInbox()


MeetMikey.Helper.Setup = new Setup()
