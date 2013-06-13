template = """
  <div class="modal hide fade modal-wide" style="display: none;">
    <div class="modal-header">
      <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
      <h3>Get more out of Mikey</h3>
    </div>
    <div class="modal-body">
      <p>Mikey is showing you stuff from the last {{mailProcessedDays}} out of the {{mailTotalDays}} total days that you've had Gmail.</p>  
      <p>Share with friends or upgrade to Mikey Premium to get more.</p>
    </div>
    <div class="modal-body">
      <div class="buttons-cluster">
        <a href="#" style="background-image:url('http://i.imgur.com/kLKxTs0.png')" id="twitterReferralButton" class="share-modal-button twitter-share"><div class="referral-button-text">twitter</div></a>
        <a href="#" style="background-image:url('http://i.imgur.com/3GOV3CY.png')" id="facebookReferralButton" class="share-modal-button facebook-share"><div class="referral-button-text">facebook</div></a>
        <a href="#" style="background-image:url('http://i.imgur.com/n2juxQ5.png')" id="upgradeButton" class="share-modal-button premium"><div class="referral-button-text">upgrade</div></a>
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

  shareTitle: 'Meet Mikey'
  shareSummary: 'Mikey makes your gmail great'

  postRender: =>
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
    link += '?text=' + encodeURIComponent @shareTitle + ': ' + @shareSummary
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
    object.mailDaysLimit = MeetMikey.globalUser.getDaysLimit()
    object.mailTotalDays = MeetMikey.globalUser.getMailTotalDays()
    object.directReferralLink = @getReferralURL 'direct'
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