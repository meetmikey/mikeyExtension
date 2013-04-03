class Setup
  inboxSelector: MeetMikey.Settings.Selectors.inboxContainer
  tabsSelector: MeetMikey.Settings.Selectors.tabsContainer

  start: =>
    $(window).one('DOMSubtreeModified', @bootstrap)

  bootstrap: =>
    localStorage.submittedBetaCode = 'gomikey' #TODO: DELETE ME BEFORE WE OPEN UP TO THE PUBLIC!!!
    MeetMikey.Helper.findSelectors @inboxSelector, @tabsSelector, @setup

  setup: (target) =>
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
    MeetMikey.globalUser.checkOnboard()

  injectModal: =>
    $('body').append $('<div id="mm-onboard-modal"></div>')
    view = new MeetMikey.View.OnboardModal el: '#mm-onboard-modal'
    view.render()
    view.on 'authorized', (userData) =>
      @authorized(userData)

  injectMainView: (target) =>
    target ?= @inboxSelector
    view = new MeetMikey.View.Main el: 'body', inboxTarget: target
    view.render()

MeetMikey.Helper.Setup = new Setup()
