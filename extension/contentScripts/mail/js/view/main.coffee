template = """
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
"""

class MeetMikey.View.Main extends MeetMikey.View.Base
  template: Handlebars.compile(template)

  events:
    'click #mm-email-tab': 'emailClick'
    'click #mm-meetmikey-tab': 'meetMikeyClick'

  emailClick: ->
    console.log 'email'
    $('#mm-content').hide()
    $('.UI').show()

  meetMikeyClick: ->
    console.log 'meet mikey'
    $('.UI').hide()
    $('#mm-content').show()
