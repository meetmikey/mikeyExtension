template = """


  <div class="modal hide fade">
    <div class="modal-header">
      <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
      <h3>Mikey is in private alpha</h3>
    </div>
    <div class="modal-body">
      
      <p>
      <input type='text' placeholder="What's the secret password?" id='betaCodeInput'>
      <div id='invalidBetaCodeLabel' style='display:none;'>Sorry, Mikey doesn't know that one. Email <a id="beta-email-help-link" href="mailto:help@mikey.com">help@mikey.com</a> to get access.</div>
      </p>
      
    </div>
    <div class="footer-buttons">
      <a href="#" id="betaCodeSubmitButton" class="button buttons">Submit</a>
      <a href="http://www.meetmikey.com" id="beta-need-code-button" class="button-grey buttons">I need a password</a>
      <a href="mailto:help@mikeyteam.com" id="beta-help-me-button" class="button-grey buttons">Help me</a>
    </div>
  </div>
"""

class MeetMikey.View.BetaCode extends MeetMikey.View.Base
  template: Handlebars.compile(template)

  events:
    'click #betaCodeSubmitButton': 'checkBetaCode'
    'click #not-now-button': 'hide'
    'click #beta-email-help-link': 'hideAndNeverAskAgain'
    'click #beta-need-code-button': 'hideAndNeverAskAgain'
    'click #beta-help-me-button': 'hideAndNeverAskAgain'

  postRender: =>
    @show()

  show: =>
    @$('.modal').modal 'show'

  hide: =>
    @$('.modal').modal 'hide'

  hideAndNeverAskAgain: =>
    @hide()
    @trigger 'neverAskAgain' 

  wrongCode: =>
    console.log 'wrongCode'
    $('#betaCodeInput').val ''
    $('#invalidBetaCodeLabel').show()

  checkBetaCode: =>
    $('#invalidBetaCodeLabel').hide()
    betaCode = $('#betaCodeInput').val()
    @trigger 'submitted', betaCode