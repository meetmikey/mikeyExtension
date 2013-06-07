template = """
  <div class="modal hide fade">
    <div class="modal-header reAuthError" style=display:none>
      <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
      <h3>Oops! Is that the email you meant to select?</h3>
    </div>
    <div class="modal-header normalModal">
      <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
      <h3>Re-Connect Mikey to your Gmail</h3>
    </div>
    <div class="modal-body reAuthError" style=display:none;>
      <p>{{errMsg}}</p>
    </div>
    <div class="modal-body normalModal">
      <p>Oops, the token Mikey uses to access your Gmail account expired or was revoked.</p>
      <p>To continue using Mikey you'll need to reconnect your gmail.</p>
    </div>
    <div class="footer-buttons">
      <a href="#" id="authorize-button" class="button buttons">Re-Connect</a>
      <a href="#" data-dismiss="modal" class="button-grey buttons">Not right now</a>
      <a href="#" id="delete" class="button-grey buttons">Delete account</a>
    </div>
  </div>
"""

class MeetMikey.View.ReAuthModal extends MeetMikey.View.BaseModal
  template: Handlebars.compile(template)

  events:
    'click #authorize-button': 'authorize'
    'click #delete': 'delete'

  postRender: =>
    if @model.get('errMsg')
      @$('.reAuthError').show()
      @$('.normalModal').hide()
    @show()

  getTemplateData: =>
    @model.decorate()

  delete: =>
    MeetMikey.Helper.OAuth.disable()
    @trigger 'disabled'
    #send api request that user is opting out of mikey
    MeetMikey.globalUser.deleteUser (res) =>
      @hide()
      @trigger 'deleted'
    @hide()

  authorize: =>
    @hide()
    MeetMikey.Helper.OAuth.openAuthWindow (errMsg, data) =>
      if errMsg
        @trigger 'emailMismatch', errMsg
      else
        @trigger 'authorized', data