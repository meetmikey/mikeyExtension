bootstrap = ->
  console.log('trying to bootstrap')
  target = $('.UI')

  if target.length > 0
    setup target
  else
    window.setTimeout(bootstrap, 200)

$(window).one('DOMSubtreeModified', bootstrap)

setup = (target) ->
  target.before $('<div id="mm-container"></div>')
  view = new MeetMikey.View.Main el: '#mm-container'
  view.render()
