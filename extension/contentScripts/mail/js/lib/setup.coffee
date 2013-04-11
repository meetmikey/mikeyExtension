class Setup
  inboxSelector: MeetMikey.Settings.Selectors.inboxContainer
  tabsSelector: MeetMikey.Settings.Selectors.tabsContainer

  start: =>
    $(window).one('DOMSubtreeModified', @bootstrap)

  bootstrap: =>
    MeetMikey.Helper.BetaAccess.checkAccess @checkSelectors

  checkSelectors: =>
    MeetMikey.Helper.findSelectors @inboxSelector, @tabsSelector, @setup

  setup: (target) =>
    @injectDropdown()
    MeetMikey.Helper.OAuth.checkUser (userData) =>
      if userData?
        @authorized(userData)
      else
        @injectModal()

  authorized: (userData) =>
    @initalizeGlobalUser userData
    @injectMainView()
    @trackLoginEvent(userData)

  trackLoginEvent: (user) =>
    MeetMikey.Helper.Mixpanel.trackEvent 'login', user

  initalizeGlobalUser: (data) =>
    MeetMikey.globalUser = new MeetMikey.Model.User data
    MeetMikey.Helper.Mixpanel.setUser MeetMikey.globalUser

  injectDropdown: =>
    view = new MeetMikey.View.Dropdown
      el: MeetMikey.Settings.Selectors.navBar, append: true
    view.render()

  injectModal: =>
    $('body').append $('<div id="mm-onboard-modal"></div>')
    view = new MeetMikey.View.OnboardModal el: '#mm-onboard-modal'
    view.render()
    view.on 'authorized', (userData) =>
      @authorized(userData)

  injectMainView: (target) =>
    target ?= @inboxSelector
    @mainView = new MeetMikey.View.Main el: 'body', inboxTarget: target, owned: false
    @mainView.render()

MeetMikey.Helper.Setup = new Setup()
