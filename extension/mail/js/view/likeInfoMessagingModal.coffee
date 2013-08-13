template = """
  <div class="modal hide fade modal-wide" style="display: none; ">
    <div class="modal-header">
      <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
      <h3>You clicked like</h3>
    </div>
    <div class="modal-body">
      <p>You're about to send an email to some people.</p>
    </div>
    <div class="footer-buttons">
      <a href="#" data-dismiss="modal" class="button buttons" id="mmLikeInfoMessagingProceed">Great!</a>
      <a href="#" data-dismiss="modal" class="button buttons" id="mmLikeInfoMessagingCancel">Cancel</a>
    </div>
  </div>
"""

class MeetMikey.View.LikeInfoMessagingModal extends MeetMikey.View.BaseModal
  template: Handlebars.compile(template)

  events:
    'hidden .modal': 'thisModalHidden'
    'click #mmLikeInfoMessagingProceed': 'proceedClicked'
    'click #mmLikeInfoMessagingCancel': 'cancelClicked'

  hasReturned: false

  proceedClicked: =>
    if ! @hasReturned
      @trigger 'proceed'
      MeetMikey.globalUser.setLikeInfoMessaging()
      @hasReturned = true

  cancelClicked: =>
    if ! @hasReturned
      @trigger 'cancel'
      @hasReturned = true

  thisModalHidden: (event) =>
    if ! @hasReturned
      @trigger 'cancel'
      @hasReturned = true
    @modalHidden event