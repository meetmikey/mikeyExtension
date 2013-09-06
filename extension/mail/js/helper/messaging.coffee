class Messaging

  lastMessageTimeKey: 'lastMessageTime'
  seenMessageKeyPrefix: 'meetmikey-hasSeenMessage-'

  shareTitle: 'Meet Mikey'
  shareSummary: 'The best way to find things in Gmail.'
  twitterTagIntro: 'Checkout'
  twitterTag: '@mikeyforgmail'

  checkLikeInfoMessaging: (resourceModel, callback) =>
    if MeetMikey.globalUser.checkLikeInfoMessaging()
      callback true
    else
      @showLikeInfoMessagingModal resourceModel, callback

  showLikeInfoMessagingModal: (resourceModel, callback) =>
    if @likeInfoMessagingModal
      @likeInfoMessagingModal.off 'proceed'
      @likeInfoMessagingModal.off 'cancel'
      @likeInfoMessagingModal = null
    $('body').append $('<div id="mm-like-info-messaging-modal"></div>')
    @likeInfoMessagingModal = new MeetMikey.View.LikeInfoMessagingModal {
          el: '#mm-like-info-messaging-modal'
      }
    @likeInfoMessagingModal.setResourceModel resourceModel
    @likeInfoMessagingModal.on 'proceed', () =>
      callback true
    @likeInfoMessagingModal.on 'cancel', () =>
      callback false
    MeetMikey.Helper.Analytics.trackEvent 'openLikeInfoMessagingModal'
    @likeInfoMessagingModal.render()

  longEnoughSinceLastMessage: () =>
    lastMessageTime = MeetMikey.Helper.LocalStore.get @lastMessageTimeKey
    if not lastMessageTime
      return true
    now = Date.now()
    timeDiff = now - lastMessageTime
    if timeDiff > MeetMikey.Constants.messagingWaitDelay
      return true
    return false

  messageShown: (messageMaskBit, notNow) =>
    if not notNow
      MeetMikey.Helper.LocalStore.set @lastMessageTimeKey, Date.now()
    localStoreKey = @seenMessageKeyPrefix + messageMaskBit
    MeetMikey.Helper.LocalStore.set localStoreKey, true

  hasSeenMessage: (messageMaskBit) =>
    localStoreKey = @seenMessageKeyPrefix + messageMaskBit
    if MeetMikey.Helper.LocalStore.get localStoreKey
      return true
    return false

  twitterReferralClick: =>
    MeetMikey.Helper.Analytics.trackEvent 'clickReferralButton', type: 'twitter'
    window.open @getTwitterShareLink(), 'sharer', 'width=626,height=236'

  facebookReferralClick: =>
    MeetMikey.Helper.Analytics.trackEvent 'clickReferralButton', type: 'facebook'
    window.open @getFacebookShareLink(), 'sharer', 'width=626,height=436'

  getReferralURL: (type) =>
    url
    switch type
      when 'twitter' then url = MeetMikey.globalUser.get 'twitterReferralLink'
      when 'facebook' then url = MeetMikey.globalUser.get 'facebookReferralLink'
      when 'direct' then url = MeetMikey.globalUser.get 'directReferralLink'
    url

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

  rateOnChromeStoreClick: (source) =>
    MeetMikey.Helper.Analytics.trackEvent 'rateOnChromeStoreClick',
      source: source
    url = MeetMikey.Constants.chromeStoreReviewURL
    window.open url
    MeetMikey.globalUser.creditUserWithPromotionAction 'chromeStoreReview'

  facebookLikeEvent: (likedURL, source) =>
    if not likedURL or likedURL isnt MeetMikey.Constants.mikeyFacebookURL
      return
    MeetMikey.Helper.Analytics.trackEvent 'facebookLikeClick',
      source: source
    MeetMikey.globalUser.creditUserWithPromotionAction 'facebookLike'

  copyTextToClipboard: (selector, source) =>
    linkText = $(selector).val()
    messageData =
      type: 'copyTextToClipboard'
      text: linkText
    chrome.runtime.sendMessage messageData, (response) ->
      #console.log 'copied text to clipboard: ', linkText

    MeetMikey.Helper.Analytics.trackEvent 'clickReferralButton',
      type: 'direct'
      source: source

  showUpgradeModal: (source) =>
    $('body').append $('<div id="mm-upgrade-modal"></div>')
    @upgradeModal = new MeetMikey.View.UpgradeModal el: '#mm-upgrade-modal'
    @upgradeModal.render()
    MeetMikey.Helper.Analytics.trackEvent 'viewUpgradeModal',
      source: source

MeetMikey.Helper.Messaging = new Messaging()