template = """
  <div class="modal hide fade modal-wide premium-modal" style="display: none;">
    <div class="modal-header">
      <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
      {{#if isPremium}}
        <h3>Share Mikey with Friends</h3>
      {{else}}
        <h3>Get more out of Mikey</h3>
      {{/if}}
    </div>
    <div class="modal-body">
      {{#if isPremium}}
        <p>You already have a premium account so we can't give you more days, but if Mikey has helped you out, we would be thrilled if you shared Mikey with your friends or rated us in the Chrome store.</p>
      {{else}}
        {{#if isFullyIndexed}}
          <p>Mikey is showing you stuff from all <strong>{{mailTotalDays}}</strong> days in your account, but you will be limited to <strong>{{mailDaysLimit}}</strong>.</p>
        {{else}}
          <p>Mikey is showing you stuff from the last <strong>{{mailDaysLimit}}</strong> out of the <strong>{{mailTotalDays}}</strong> total days that you've had this Gmail account.</p>
        {{/if}}
        <p>Share with friends, rate us in the Chrome store, or upgrade to Mikey Premium to get more days.</p>
      {{/if}}
    </div>
    <div class="modal-body">
      <div class="buttons-cluster">
        <a href="#" id="twitterReferralButton" class="share-modal-button twitter-share"><div class="referral-button-text">twitter</div></a>
        <a href="#" id="facebookReferralButton" class="share-modal-button facebook-share"><div class="referral-button-text">facebook</div></a>
        <a href="#" id="rateOnChromeStoreButton" class="share-modal-button chrome-share"><div class="referral-button-text">rate mikey</div></a>
        {{#unless isGrantedPremium}}
          <a href="#" id="upgradeButton" class="share-modal-button premium">
            <div class="referral-button-text">upgrade</div>
          </a>
        {{/unless}}
      </div>
      Or share this URL<br>
      <input style="padding-bottom: 5px;" id="directReferralLinkText" type="text" value="{{directReferralLink}}"><a href="#" id="copyButton" style="margin-left:-2px;" class="button buttons">Copy</a>
    </div>
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
    @creditUserWithReview()

  creditUserWithReview: =>
    email = MeetMikey.globalUser?.get('email')
    MeetMikey.Helper.callAPI
      url: 'creditChromeStoreReview'
      type: 'POST'
      data:
        userEmail: email
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
    @upgradeModal.notifyAboutUpgradeInterest()