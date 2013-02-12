template = """
  <div class="modal hide fade">
    <div class="modal-header">
      <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
      <h3> Authorize Meet Mikey </h3>
    </div>
    <div class="modal-body">
      <p>You must authorize Meet Mikey to use our awesome features.</p>
    </div>
    <div class="modal-footer">
      <a href="#" id="not-now-button" class="btn">Not Now</a>
      <a href="#" id="authorize-button" class="btn btn-primary">Authorize</a>
    </div>
  </div>
"""

class MeetMikey.View.OnboardModal extends MeetMikey.View.Base
  template: Handlebars.compile(template)

  events:
    'click #authorize-button': 'authorize'
    'click #not-now-button': 'hide'

  postRender: =>
    @show()

  show: =>
    @$('.modal').modal 'show'

  hide: =>
    @$('.modal').modal 'hide'

  authorize: =>
    MeetMikey.Helper.OAuth.openAuthWindow (data) =>
      @trigger 'authorized', data
    @hide()
