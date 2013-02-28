class Setup
  inboxSelector: '.UI'
  tabsSelector: "[id=':ro'] .nH.aqK"

  start: =>
    $(window).one('DOMSubtreeModified', @bootstrap)

  bootstrap: =>
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

  initalizeGlobalUser: (data) =>
    MeetMikey.globalUser = new MeetMikey.Model.User data

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
