class Setup
  targetSelector: '.UI'
  start: =>
    $(window).one('DOMSubtreeModified', @bootstrap)

  bootstrap: =>
    console.log('trying to bootstrap')
    target = $(@targetSelector)
    if target.length > 0
      @setup target
    else
      window.setTimeout(@bootstrap, 200)

  setup: (target) =>
    MeetMikey.Helper.OAuth.refresh (userData) =>
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
    target ?= @targetSelector
    view = new MeetMikey.View.Main el: 'body', inboxTarget: target
    view.render()

MeetMikey.Helper.Setup = new Setup()
