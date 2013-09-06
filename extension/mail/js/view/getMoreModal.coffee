template = """
  <div class="modal hide fade modal-wide premium-modal" style="display: none;">
    <div class="modal-header">
      <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
      {{#if isPremium}}
        <h3>Share Mikey with Friends</h3>
      {{else}}
        <h3>Get more Mikey</h3>
      {{/if}}
    </div>
    <div class="modal-body">
      {{#if isPremium}}
        <p>You already have a premium account so we can't give you more days, but if Mikey has helped you out, you could really help Mikey out by:</p>
      {{else}}
        {{#if isFullyIndexed}}
          <p>Mikey is showing you stuff <strong>{{mailTotalDays}}</strong> days in your account, but you will be limited to <strong>{{mailDaysLimit}}</strong>. Not to worry though, you can get more days by:</p>
        {{else}}
          <p>Mikey is showing you <strong>{{mailDaysLimit}}</strong> out of the <strong>{{mailTotalDays}}</strong> total days that you've had this Gmail account.</p><p> 
            We've made it super easy to get more days by:</p>
        {{/if}}
        
      {{/if}}
    </div>
    <div class="modal-body">
      
      <div class="get-more-options">
        <div class="modal-subheader">
          <div class="modal-subheader-text">
            Sharing with friends
          </div>
          <div class="modal-subtext">
            30 days for every referral 
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

      <div class="get-more-options">
        <div class="modal-subheader">
          <div class="modal-subheader-text">
            Showing Mikey love
          </div>
          <div class="modal-subtext">
            15 days for chrome store or facebook support
          </div>
        </div>
        <div class="buttons-cluster">
          <a href="#" id="rateOnChromeStoreButton" class="share-modal-button chrome-share"><div class="referral-button-text">Rate Mikey</div></a>
          <div id="facebookLikeButton">
            <fb:like href="https://www.facebook.com/pages/Mikey-for-Gmail/1400138380211355?ref=br_tf" width="300" show_faces="true" send="false"></fb:like>
          </div>
        </div>
      </div>

      {{#unless isGrantedPremium}}
      <div class="get-more-options">
        <div class="modal-subheader">
          <div class="modal-subheader-text">
            Upgrading
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
      {{/unless}}


    <div class="footer-buttons">
     
    </div>
  </div>
"""

class MeetMikey.View.GetMoreModal extends MeetMikey.View.BaseModal
  template: Handlebars.compile(template)

  events:
    'click #twitterReferralButton': 'twitterReferralClick'
    'click #facebookReferralButton': 'facebookReferralClick'
    'click #rateOnChromeStoreButton': 'rateOnChromeStoreClick'
    'click #upgradeButton': 'showUpgradeModal'
    'click #copyButton': 'copyTextToClipboard'
    'hidden .modal': 'modalHidden'

  shareTitle: 'Meet Mikey'
  shareSummary: 'The best way to find things in Gmail.'
  twitterTagIntro: 'Checkout'
  twitterTag: '@mikeyforgmail'

  postRender: =>
    if MeetMikey.globalUser?.isPremium()
      @$('.mm-download-tooltip').tooltip placement: 'bottom'
    super
    MeetMikey.Helper.Analytics.trackEvent 'viewGetMoreModal'
    FB.XFBML.parse document.getElementById('facebookLikeButton')
    @bindFacebookEvents()

  hide: =>
    @$('.modal').modal 'hide'
    @remove()
    @unbindFacebookEvents()

  bindFacebookEvents: () =>
    @unbindFacebookEvents()
    FB.Event.subscribe 'edge.create', @facebookLikeEvent

  unbindFacebookEvents: () =>
    FB.Event.unsubscribe 'edge.create', @facebookLikeEvent

  facebookLikeEvent: (likedURL) =>
    if not likedURL or likedURL isnt MeetMikey.Constants.mikeyFacebookURL
      return
    MeetMikey.Helper.Analytics.trackEvent 'facebookLikeClick'
    @creditUserWithPromotionAction 'facebookLike'

  twitterReferralClick: =>
    MeetMikey.Helper.Analytics.trackEvent 'clickReferralButton', type: 'twitter'
    window.open @getTwitterShareLink(), 'sharer', 'width=626,height=236'

  facebookReferralClick: =>
    MeetMikey.Helper.Analytics.trackEvent 'clickReferralButton', type: 'facebook'
    window.open @getFacebookShareLink(), 'sharer', 'width=626,height=436'

  rateOnChromeStoreClick: =>
    MeetMikey.Helper.Analytics.trackEvent 'rateOnChromeStoreClick'
    url = MeetMikey.Constants.chromeStoreReviewURL
    window.open url
    @hide()
    @creditUserWithPromotionAction 'chromeStoreReview'

  creditUserWithPromotionAction: (promotionType) =>
    MeetMikey.Helper.callAPI
      url: 'creditPromotionAction'
      type: 'POST'
      data:
        'promotionType': promotionType
      complete: () =>
        MeetMikey.globalUser.refreshFromServer()

  getTwitterShareLink: =>
    link = 'https://twitter.com/intent/tweet'
    link += '?text=' + encodeURIComponent @twitterTagIntro + ' ' + @twitterTag + ': ' + @shareSummary
    link += '&url=' + encodeURIComponent @getReferralURL 'twitter'
    link

  getFacebookShareLink: =>
    link = 'https://www.facebook.com/sharer/sharer.php?s=100'
    link += '&p[url]=' + encodeURIComponent @getReferralURL 'facebook'
    link += '&p[title]=' + encodeURIComponent @shareTitle
    link += '&p[summary]=' + encodeURIComponent @shareSummary
    link

  getTemplateData: =>
    object = {}
    object.mailDaysLimit = MeetMikey.globalUser?.getDaysLimit()
    object.mailTotalDays = MeetMikey.globalUser?.getMailTotalDays()
    object.directReferralLink = @getReferralURL 'direct'
    object.isPremium = MeetMikey.globalUser.isPremium()
    object.isGrantedPremium = MeetMikey.globalUser.get('isGrantedPremium')
    object.isFullyIndexed = ( MeetMikey.globalUser?.getDaysLimit() >= MeetMikey.globalUser?.getMailTotalDays() )
    object

  getReferralURL: (type) =>
    url
    switch type
      when 'twitter' then url = MeetMikey.globalUser.get 'twitterReferralLink'
      when 'facebook' then url = MeetMikey.globalUser.get 'facebookReferralLink'
      when 'direct' then url = MeetMikey.globalUser.get 'directReferralLink'
    url

  copyTextToClipboard: =>
    linkText = $('#directReferralLinkText').val()
    messageData =
      type: "copyTextToClipboard"
      text: linkText
    chrome.runtime.sendMessage messageData, (response) ->
      #console.log 'copied text to clipboard: ', linkText

    MeetMikey.Helper.Analytics.trackEvent 'clickReferralButton', type: 'direct'

  showUpgradeModal: =>
    @hide()
    $('body').append $('<div id="mm-upgrade-modal"></div>')
    @upgradeModal = new MeetMikey.View.UpgradeModal el: '#mm-upgrade-modal'
    @upgradeModal.render()
    MeetMikey.Helper.Analytics.trackEvent 'viewUpgradeModal', {link: 'upgrade'}