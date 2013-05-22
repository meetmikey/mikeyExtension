template = """
  <div class="modal hide fade">
    <div class="modal-header">
      <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
      <h3>Re-Connect Mikey to your Gmail</h3>
    </div>
    <div class="modal-body">
      <p>Oops, the token Mikey uses to access your Gmail account expired or was revoked.</p>
      <p>To continue using Mikey you'll need to reconnect your gmail.</p>
    </div>
    <div class="footer-buttons">
      <a href="#" id="authorize-button" class="button buttons">Re-Connect</a>
      <a href="#" id="not-now-button" class="button-grey buttons">Not right now</a>
      <a href="#" id="delete" class="button-grey buttons">Delete account</a>
    </div>
  </div>
"""

class MeetMikey.View.ReAuthModal extends MeetMikey.View.Base
  template: Handlebars.compile(template)

  events:
    'click #authorize-button': 'authorize'
    'click #not-now-button': 'hide'
    'click #delete': 'delete'
    'click .close' : 'hide'

  postRender: =>
    @show()

  show: =>
    @$('.modal').modal 'show'

  hide: =>
    @$('.modal').modal 'hide'
    @remove()

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
    MeetMikey.Helper.OAuth.openAuthWindow (data) =>
      @trigger 'authorized', data