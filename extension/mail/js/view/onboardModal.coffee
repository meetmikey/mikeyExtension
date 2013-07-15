template = """
  <div class="modal hide fade">
    <div class="modal-header onboardError" style=display:none>
      <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
      <h3>Oops! Is that the email you meant to select?</h3>
    </div>
    <div class="modal-header normalModal">
      <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
      <h3>Connect Mikey to your Gmail</h3>
    </div>
    <div class="modal-body onboardError" style=display:none;>
      <p>{{errMsg}}</p>
    </div>
    <div class="modal-body normalModal">
      <p>Mikey needs access to your Gmail in order to perform his magic.</p>
      <p>Once you connect, it should take a few hours to process.</p>
    </div>
    <div class="footer-buttons">
      <a href="#" id="authorize-button" class="button buttons">Connect</a>
      <a href="#" data-dismiss="modal" class="button-grey buttons">Not right now</a>
      <a href="#" id="never-button" class="button-grey buttons">Never this account</a>
    </div>
  </div>
"""

class MeetMikey.View.OnboardModal extends MeetMikey.View.BaseModal
  template: Handlebars.compile(template)

  events:
    'click #authorize-button': 'authorize'
    'click #never-button': 'doNotAsk'
    'hidden .modal': 'modalHidden'

  postRender: =>
    if @model.get('errMsg')
      @$('.onboardError').show()
      @$('.normalModal').hide()
    @show()
    
  doNotAsk: =>
    MeetMikey.Helper.OAuth.disable()
    @trigger 'disabled'
    @hide()

  getTemplateData: =>
    @model.decorate()

  authorize: =>
    @hide()
    MeetMikey.Helper.OAuth.openAuthWindow (errMsg, data) =>
      if errMsg
        @trigger 'emailMismatch', errMsg
      else
        @trigger 'authorized', data