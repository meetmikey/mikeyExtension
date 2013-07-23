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
        <p>You already have a premium account so we can't give you more days, but if Mikey has helped you out, we would be thrilled if you shared Mikey with your friends.</p>
      {{else}}
        {{#if isFullyIndexed}}
          <p>Mikey is showing you stuff from all {{mailTotalDays}} days in your account, but you're limited to {{mailDaysLimit}}.</p>
        {{else}}
          <p>Mikey is showing you stuff from the last {{mailDaysLimit}} days (out of the {{mailTotalDays}} total days that you've had this Gmail account).</p>
        {{/if}}
        <p>Share with friends or upgrade to Mikey Premium to get more.</p>
      {{/if}}
    </div>
    <div class="modal-body">
      <div class="buttons-cluster">
        <a href="#" id="twitterReferralButton" class="share-modal-button twitter-share"><div class="referral-button-text">twitter</div></a>
        <a href="#" id="facebookReferralButton" class="share-modal-button facebook-share"><div class="referral-button-text">facebook</div></a>
        {{#if isPremium}}
          <a href="#" class="share-modal-button premium upgraded mm-download-tooltip" data-toggle="tooltip" title="You already have a premium account">
            <div class="referral-button-text">upgraded</div></a> 
        {{else}}
          <a href="#" id="upgradeButton" class="share-modal-button premium">
            <div class="referral-button-text">upgrade</div>
          </a>
        {{/if}}
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
    @notifyAboutUpgradeInterest()

  notifyAboutUpgradeInterest: =>
    #TEMP!!!!! GET RID OF FALSE!!!
    if false and MeetMikey.Constants.env is 'production'
      MeetMikey.Helper.Analytics.trackEvent 'viewUpgradeModal'
      email = MeetMikey.globalUser?.get('email')
      MeetMikey.Helper.callAPI
        url: 'upgrade'
        type: 'POST'
        data:
          userEmail: email
          