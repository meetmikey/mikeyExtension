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
    MeetMikey.Helper.OAuth.authorize (data) =>
      @injectMainView(target)

  injectModal: =>

  injectMainView: (target) =>
    target.before $('<div id="mm-container"></div>')
    view = new MeetMikey.View.Main el: '#mm-container'
    view.render()

MeetMikey.Helper.Setup = new Setup()
