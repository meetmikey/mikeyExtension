template = """
  <div class="modal hide fade">
    <div>
      Enter your Meet Mikey beta code: <input type='text' id='betaCodeInput'>
      <a href="#" id="betaCodeSubmitButton" class="button buttons">Submit</a>
      <div id='invalidBetaCodeLabel' style='display:none;'>Invalid code</div>
    </div>

    <div>
      Want a beta code?  <a href="http://meetmikey.com" target="_blank">Sign up</a>
    </div>

    <div>
      Having trouble?  <a href="http://mikey.uservoice.com/" target="_blank">Contact Mikey's support team</a>
    </div>
  </div>
"""

class MeetMikey.View.BetaCode extends MeetMikey.View.Base
  template: Handlebars.compile(template)

  events:
    'click #betaCodeSubmitButton': 'checkBetaCode'

  postRender: =>
    @show()

  show: =>
    @$('.modal').modal 'show'

  hide: =>
    @$('.modal').modal 'hide'

  wrongCode: =>
    console.log 'wrongCode'
    $('#betaCodeInput').val ''
    $('#invalidBetaCodeLabel').show()

  checkBetaCode: =>
    $('#invalidBetaCodeLabel').hide()
    betaCode = $('#betaCodeInput').val()
    @trigger 'submitted', betaCode