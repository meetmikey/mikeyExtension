template = """


  <div class="modal hide fade">
    <div class="modal-header">
      <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
      <h3>Mikey is in private alpha</h3>
    </div>
    <div class="modal-body">
      
      <p>Have a code? 
      <input type='text' id='betaCodeInput'>
      <div id='invalidBetaCodeLabel' style='display:none;'>Invalid code</div>
      </p>
      
    </div>
    <div class="footer-buttons">
      <a href="#" id="betaCodeSubmitButton" class="button buttons">Submit</a>
      <a href="http://www.meetmikey.com" id="beta-need-code-button" class="button-grey buttons">I need a code</a>
      <a href="mailto:feedback@mikeyteam.com" id="beta-help-me-button" class="button-grey buttons">Help me</a>
    </div>
  </div>
"""

class MeetMikey.View.BetaCode extends MeetMikey.View.Base
  template: Handlebars.compile(template)

  events:
    'click #betaCodeSubmitButton': 'checkBetaCode'
    'click #not-now-button': 'hide'
    'click #beta-need-code-button': 'hide'
    'click #beta-help-me-button': 'hide'

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