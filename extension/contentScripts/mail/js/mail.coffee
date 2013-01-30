template = """
  <div id="mm-container">
    <ul class="mm-tabs">
      <li id="mm-email-tab">
        <a href="#">Email</a>
      </li>
      <li id="mm-meetmikey-tab">
        <a href="#">Meet Mikey</a>
      </li>
    </ul>
    <div id="mm-content" style="display: none;">
      MIKEY TAB IS HERE!!!!!!!
    </div>
  </div>
"""

console.log('???')

bootstrap = ->
  console.log('trying to bootstrap')
  target = $('.UI')

  if target.length > 0
    setup target
  else
    window.setTimeout(bootstrap, 200)

$(window).one('DOMSubtreeModified', bootstrap)

setup = (target) ->
  console.log 'setting up'
  target.before(template)
  $('#mm-email-tab').on 'click', ->
    console.log 'email'
    $('#mm-content').hide()
    $('.UI').show()
  $('#mm-meetmikey-tab').on 'click', ->
    console.log 'meet mikey'
    $('.UI').hide()
    $('#mm-content').show()



