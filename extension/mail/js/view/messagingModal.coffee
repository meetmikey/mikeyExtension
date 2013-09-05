chromeStoreReviewTemplate = """
  <div class="modal hide fade modal-wide" style="display: none; ">
    <div class="modal-header">
      <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
      <h3>Get more Mikey days!</h3>
    </div>
    <div class="modal-body">
      <p>Review us in the Chrome Store</p>
    </div>
    <div class="footer-buttons">
      <a href="#" data-dismiss="modal" class="button buttons">Thanks</a>
    </div>
  </div>
"""

facebookLikeTemplate = """
  <div class="modal hide fade modal-wide" style="display: none; ">
    <div class="modal-header">
      <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
      <h3>Get more Mikey days!</h3>
    </div>
    <div class="modal-body">
      <p>Like Mikey on Facebook</p>
    </div>
    <div class="footer-buttons">
      <a href="#" data-dismiss="modal" class="button buttons">Thanks</a>
    </div>
  </div>
"""

socialShareTemplate = """
  <div class="modal hide fade modal-wide" style="display: none; ">
    <div class="modal-header">
      <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
      <h3>Get more Mikey days!</h3>
    </div>
    <div class="modal-body">
      <p>Share Mikey</p>
    </div>
    <div class="footer-buttons">
      <a href="#" data-dismiss="modal" class="button buttons">Thanks</a>
    </div>
  </div>
"""

upgradeToPremiumTemplate = """
  <div class="modal hide fade modal-wide" style="display: none; ">
    <div class="modal-header">
      <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
      <h3>Get more Mikey days!</h3>
    </div>
    <div class="modal-body">
      <p>Upgrade to Premium</p>
    </div>
    <div class="footer-buttons">
      <a href="#" data-dismiss="modal" class="button buttons">Thanks</a>
    </div>
  </div>
"""

class MeetMikey.View.MessagingModal extends MeetMikey.View.BaseModal

  events:
    'hidden .modal': 'modalHidden'

  shouldShow: () =>
    template = @getTemplate()
    if not template
      return false
    if MeetMikey.globalUser and MeetMikey.globalUser.get 'isPremium'
      return false
    if not MeetMikey.Helper.Messaging.longEnoughSinceLastMessage()
      return false
    return true

  postRender: =>
    @messageShown()
    @show()

  template: () =>
    Handlebars.compile( @getTemplate() )()

  messageShown: () =>
    template = @getTemplate()
    if not template
      return
    messageMaskBit = @getMessageMaskBit template
    MeetMikey.Helper.Messaging.messageShown messageMaskBit
    MeetMikey.globalUser.setNewMessageMaskBit messageMaskBit

  getMessageMaskBit: (template) =>
    if not template
      return 0

    maskBits = MeetMikey.Constants.userMessagingMaskBits
    if template is chromeStoreReviewTemplate
      return maskBits.chromeStoreReview
    if template is facebookLikeTemplate
      return maskBits.facebookLike
    if template is socialShareTemplate
      return maskBits.socialShare
    if template is upgradeToPremiumTemplate
      return maskBits.upgradeToPremium
    return 0

  getTemplate: () =>

    if not MeetMikey.globalUser
      return ''
    
    user = MeetMikey.globalUser
    maskBits = MeetMikey.Constants.userMessagingMaskBits
    
    if not user.hasSeenMessage maskBits.chromeStoreReview
      return chromeStoreReviewTemplate

    if not user.hasSeenMessage maskBits.facebookLike
      return facebookLikeTemplate

    if not user.hasSeenMessage maskBits.socialShare
      return socialShareTemplate

    if not user.hasSeenMessage maskBits.upgradeToPremium
      return upgradeToPremiumTemplate
    
    return ''