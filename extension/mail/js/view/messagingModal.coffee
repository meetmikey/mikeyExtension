templates = {}

templates.chromeStoreReview = """
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

templates.facebookLike = """
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

templates.socialShare = """
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

templates.upgradeToPremium = """
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
    templateKey = @getTemplateKey()
    if not templateKey
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
    templateKey = @getTemplateKey()
    if not templateKey
      return
    template = templates[templateKey]
    messageMaskBit = @getMessageMaskBit templateKey
    MeetMikey.Helper.Messaging.messageShown messageMaskBit
    MeetMikey.globalUser.setNewMessageMaskBit messageMaskBit
    MeetMikey.Helper.Analytics.trackEvent 'viewMessagingModal',
      whichModal: templateKey

  getMessageMaskBit: (templateKey) =>
    if not templateKey
      return 0
    messageMaskBits = MeetMikey.Constants.userMessagingMaskBits
    messageMaskBit = messageMaskBits[templateKey]
    if not messageMaskBit
      return 0
    return messageMaskBit

  userShouldSeeMessage: (messageMaskBit) =>
    if not messageMaskBit
      return false
    user = MeetMikey.globalUser
    if not user
      return false
    messageMaskBits = MeetMikey.Constants.userMessagingMaskBits
    if messageMaskBit is messageMaskBits.chromeStoreReview and user.get('clickedChromeStoreReview')
      return false
    if messageMaskBit is messageMaskBits.facebookLike and user.get('clickedFacebookLike')
      return false
    return true

  getTemplateKey: () =>
    user = MeetMikey.globalUser
    if not user
      return null
    for templateKey, template of templates
      messageMaskBit = @getMessageMaskBit templateKey
      if messageMaskBit and not user.hasSeenMessage(messageMaskBit) and @userShouldSeeMessage(messageMaskBit)
        return templateKey
    return null
      
  getTemplate: () =>
    templateKey = @getTemplateKey()
    if not templateKey or not templates[templateKey]
      return null
    return templates[templateKey]