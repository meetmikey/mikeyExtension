footerTemplate = """  
  <div class="footer-buttons">
    <div class="footer-mail-count">
      You have <strong><div class="daysLimitContainer" style="display:inline-block;">{{mailDaysLimit}}</div></strong> out of <strong>{{mailTotalDays}}</strong> total days.
    </div>
    <a href="#" data-dismiss="modal" class="button buttons closeMessagingModal">Got it.</a>
  </div>
"""
templates = {}

templates.chromeStoreReview = """
  <div class="modal hide fade modal-wide modal-messenger" style="display: none; ">
    <div class="modal-header">
      <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
      <h3>Did you know you could get {{numDaysForChromeOrFacebookSupport}} more days of storage in 20 seconds?</h3>
    </div>
    <div class="modal-body">
      
        <div class="modal-subheader">
          <div class="modal-subheader-text">
            Review Mikey in the Chrome store
          </div>
          <div class="modal-subtext">
            {{numDaysForChromeOrFacebookSupport}} days for two clicks 
          </div>
        </div>
        <div class="buttons-cluster">
          <a href="#" id="rateOnChromeStoreButton" class="share-modal-button chrome-share"><div class="referral-button-text">Show Mikey some love</div></a>
        </div>
      
    </div>
    """ + footerTemplate + """
  </div>
"""

templates.facebookLike = """
  <div class="modal hide fade modal-wide modal-messenger" style="display: none; ">
    <div class="modal-header">
      <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
      <h3>Did you know you could get {{numDaysForChromeOrFacebookSupport}} more days for a Facebook like?</h3>
    </div>
    <div class="modal-body">
      
        <div class="modal-subheader">
          <div class="modal-subheader-text">
            Show Mikey some Facebook love
          </div>
          <div class="modal-subtext">
            {{numDaysForChromeOrFacebookSupport}} days for two clicks 
          </div>
        </div>
        <div class="buttons-cluster">
          <a href="#" id="facebookLikeButton">
            <fb:like href="https://www.facebook.com/pages/Mikey-for-Gmail/1400138380211355?ref=br_tf" width="300" show_faces="true" send="false"></fb:like>
          </a>
        </div>
      
    </div>
    """ + footerTemplate + """
  </div>
"""

templates.socialShare = """
  <div class="modal hide fade modal-wide modal-messenger" style="display: none; ">
    <div class="modal-header">
      <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
      <h3>Get more days of Mikey storage</h3>
    </div>
    <div class="modal-body">
      
        <div class="modal-subheader">
          <div class="modal-subheader-text">
            Share with friends
          </div>
          <div class="modal-subtext">
            {{numDaysForReferral}} days for every referral 
          </div>
        </div>
        <div class="buttons-cluster">
          <a href="#" id="twitterReferralButton" class="share-modal-button twitter-share"><div class="referral-button-text">Tweet</div></a>
          <a href="#" id="facebookReferralButton" class="share-modal-button facebook-share"><div class="referral-button-text">Share</div></a>
          <div class="url-copy-box">
            <input id="directReferralLinkText" type="text" value="{{directReferralLink}}">
            <a href="#" id="copyButton" class="copy-button" style="margin-left:-5px;">Copy</a>
          </div>
        </div>
      
    </div>
   """ + footerTemplate + """
  </div>
"""

templates.upgradeToPremium = """
  <div class="modal hide fade modal-wide modal-messenger" style="display: none; ">
    <div class="modal-header">
      <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
      <h3>Wish you had more days of Mikey storage? Consider an upgrade.</h3>
    </div>
    <div class="modal-body">
    
      <div class="modal-subheader">
        <div class="modal-subheader-text">
          Mikey Premium
        </div>
        <div class="modal-subtext">
          Simple monthly plans. no tricks.
        </div>
      </div>
          
      <div class="buttons-cluster">
         <a href="#" id="upgradeButton" class="share-modal-button premium">
          <div class="referral-button-text">check out the premium plans</div>
        </a>
      </div>
    </div>
    """ + footerTemplate + """
  </div>
"""


class MeetMikey.View.MessagingModal extends MeetMikey.View.BaseModal

  events:
    'click #twitterReferralButton': 'twitterReferralClick'
    'click #facebookReferralButton': 'facebookReferralClick'
    'click #rateOnChromeStoreButton': 'rateOnChromeStoreClick'
    'click #upgradeButton': 'showUpgradeModal'
    'click #copyButton': 'copyTextToClipboard'
    'hidden .modal': 'modalHidden'

  postInitialize: =>
    MeetMikey.globalUser?.on 'change', @updateMailDaysLimit

  postRender: =>
    @messageShown()
    @show()
    FB.XFBML.parse document.getElementById('facebookLikeButton')
    @bindFacebookEvents()

  hide: =>
    @$('.modal').modal 'hide'
    @remove()
    @unbindFacebookEvents()
    MeetMikey.globalUser?.off 'change', @updateMailDaysLimit

  bindFacebookEvents: () =>
    @unbindFacebookEvents()
    FB.Event.subscribe 'edge.create', @facebookLikeEvent

  unbindFacebookEvents: () =>
    FB.Event.unsubscribe 'edge.create', @facebookLikeEvent

  updateMailDaysLimit: () =>
    newDaysLimit = MeetMikey.globalUser.getDaysLimit()
    $('.daysLimitContainer').html newDaysLimit

  rateOnChromeStoreClick: =>
    MeetMikey.Helper.Messaging.rateOnChromeStoreClick 'messagingModal'
    @hide()

  facebookLikeEvent: (likedURL) =>
    MeetMikey.Helper.Messaging.facebookLikeEvent likedURL, 'messagingModal'
    $('.closeMessagingModal').html 'Thanks!'

  twitterReferralClick: =>
    MeetMikey.Helper.Messaging.twitterReferralClick()

  facebookReferralClick: =>
    MeetMikey.Helper.Messaging.facebookReferralClick()

  copyTextToClipboard: =>
    MeetMikey.Helper.Messaging.copyTextToClipboard '#directReferralLinkText', 'messagingModal'

  showUpgradeModal: =>
    MeetMikey.Helper.Messaging.showUpgradeModal 'messagingModal'
    @hide()

  shouldShow: () =>
    templateKey = @getTemplateKey()
    if not templateKey
      return false
    if not MeetMikey.globalUser
      return false
    if MeetMikey.globalUser.get 'isPremium'
      return false
    if MeetMikey.globalUser.get 'onboarding'
      return false
    if MeetMikey.globalUser.getDaysLimit() >= MeetMikey.globalUser.getMailTotalDays()
      return false
    if not MeetMikey.Helper.Messaging.longEnoughSinceLastMessage()
      return false
    return true

  template: () =>
    template = @getTemplate()
    if template
      return Handlebars.compile( template )( @getTemplateData() )
    return () =>
      return ''

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

  getTemplateData: =>
    object = {}
    object.mailDaysLimit = MeetMikey.globalUser?.getDaysLimit()
    object.mailTotalDays = MeetMikey.globalUser?.getMailTotalDays()
    object.directReferralLink = MeetMikey.Helper.Messaging.getReferralURL('direct')
    object.isFullyIndexed = ( MeetMikey.globalUser?.getDaysLimit() >= MeetMikey.globalUser?.getMailTotalDays() )
    object.numDaysForChromeOrFacebookSupport = MeetMikey.Constants.numDaysForChromeOrFacebookSupport
    object.numDaysForReferral = MeetMikey.Constants.numDaysForReferral
    object