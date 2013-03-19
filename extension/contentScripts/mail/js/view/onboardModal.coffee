template = """
  <div class="modal hide fade">
    <div class="modal-header">
      <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
      <h3>Get Mikey</h3>
    </div>
    <div class="modal-body">
      <p>You need to let Mikey access your Gmail in order to let him work his magic.</p>
    </div>


    <div class="footer-buttons">
      <a href="#" id="authorize-button" class="button buttons">Connect</a>
      <a href="#" id="not-now-button" class="button-grey buttons">Not right now</a>
      <a href="#" id="not-now-button" class="button-grey buttons">Never this account</a>
      
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
