template = """
<div id="example" class="modal hide fade modal-wide" style="display: none; ">
    <div class="modal-header">
      <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
      <h3>Sorry to see you go! Your account will be deleted shortly.</h3>
    </div>
    <div class="modal-body">
      <p>If you deleted your account accidently, please email <a href="mailto:support@mikeyteam.com"> support</a></p>
      <p>Otherwise, Mikey would love <a href="mailto:feedback@mikeyteam.com"> feedback</a> on your experience.</p>
    </div>
    <div class="footer-buttons">
      <a href="#" id="done" data-dismiss="modal" class="button buttons thanks-button">Thanks</a>
    </div>
  </div>
"""

class MeetMikey.View.FeedbackModal extends MeetMikey.View.Base
  template: Handlebars.compile(template)

  events:
    'click #done': 'hide'
    'click .close' : 'hide'

  postRender: =>
    @show()

  show: =>
    console.log 'show'
    $('.modal').modal 'hide'
    @$('.modal').modal 'show'

  hide: =>
    console.log 'hide'
    @$('.modal').modal 'hide'
    @remove()

  teardown: =>
    console.log 'teardown feedback'