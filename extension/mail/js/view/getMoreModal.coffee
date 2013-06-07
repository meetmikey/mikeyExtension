template = """
  <div class="modal hide fade modal-wide" style="display: none; ">
    <div class="modal-header">
      <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
      <h3>Get more Mikey</h3>
    </div>
    <div class="modal-body">
      <p>Mikey has gone through {{mailProcessedDays}} of your {{mailTotalDays}} gmail days.  Get more days by sharing with friends.</p>
    </div>
    <div class="modal-body">
      <input id="directReferralLinkText" type="text" value="{{directReferralLink}}"><a href="#" id="copyButton" class="button buttons">Copy</a>
      <a href="#" onclick="window.open('{{twitterShareLink}}', 'sharer', 'width=626,height=236');">tweet it</a>
      <a href="#" onclick="window.open('{{facebookShareLink}}', 'sharer', 'width=626,height=436');">share on facebook</a>
    </div>
    <div class="footer-buttons">
      <a href="#" data-dismiss="modal" class="button buttons">Nice</a>
    </div>
  </div>
"""

class MeetMikey.View.GetMoreModal extends MeetMikey.View.BaseModal
  template: Handlebars.compile(template)

  events:
    'click #copyButton': 'copyTextToClipboard'

  shareTitle: 'Meet Mikey'
  shareSummary: 'Mikey makes your gmail great'

  getTwitterShareLink: =>
    link = 'https://twitter.com/intent/tweet'
    link += '?text=' + encodeURIComponent @shareTitle + ': ' + @shareSummary
    link += '&url=' + encodeURIComponent @getReferralURL 'twitter'
    console.log 'twitter share link: ' + link
    link

  getFacebookShareLink: =>
    link = 'https://www.facebook.com/sharer/sharer.php?s=100'
    link += '&p[url]=' + encodeURIComponent @getReferralURL 'facebook'
    link += '&p[title]=' + encodeURIComponent @shareTitle
    link += '&p[summary]=' + encodeURIComponent @shareSummary
    console.log 'facebook share link: ' + link
    link

  getTemplateData: =>
    object = {}
    object.mailProcessedDays = MeetMikey.globalUser.getMailProcessedDays()
    object.mailTotalDays = MeetMikey.globalUser.getMailTotalDays()
    object.twitterShareLink = @getTwitterShareLink()
    object.facebookShareLink = @getFacebookShareLink()
    object.directReferralLink = @getReferralURL 'direct'
    object.userId = MeetMikey.globalUser.get('_id')
    object

  getReferralURL: (type) =>
    url
    switch type
      when 'twitter' then url = MeetMikey.globalUser.get 'twitterReferralLink'
      when 'facebook' then url = MeetMikey.globalUser.get 'facebookReferralLink'
      when 'direct' then url = MeetMikey.globalUser.get 'directReferralLink'
    url

  copyToClipboard_test: =>
    console.log 'copying'
    
    document.execCommand 'SelectAll'
    document.execCommand 'Copy', false, null

  copyTextToClipboard: =>
    linkText = $('#directReferralLinkText').val()
    messageData =
      type: "copyTextToClipboard"
      text: linkText
    console.log 'copying text to clipboard: ' + linkText
    chrome.runtime.sendMessage messageData, (response) ->
      if ! response || ! response.isSuccess
        console.log 'error while copying text to clipboard, response: ', response
      else
        console.log 'successfully copied text to clipboard: ', linkText