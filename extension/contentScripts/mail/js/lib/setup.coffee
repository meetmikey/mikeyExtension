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
    MeetMikey.Helper.OAuth.refresh (data) =>
      if data?
        @injectMainView()
      else
        @injectModal()

  injectModal: =>
    $('body').append $('<div id="mm-onboard-modal"></div>')
    view = new MeetMikey.View.OnboardModal el: '#mm-onboard-modal'
    view.render()
    view.on 'authorized', =>
      @injectMainView()

  injectMainView: (target) =>
    target ?= $(@targetSelector)
    target.before $('<div id="mm-container"></div>')
    view = new MeetMikey.View.Main el: '#mm-container'
    view.render()

MeetMikey.Helper.Setup = new Setup()
