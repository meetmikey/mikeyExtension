class Messaging

  lastMessageTimeKey: 'lastMessageTime'
  seenMessageKeyPrefix: 'meetmikey-hasSeenMessage-'

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

MeetMikey.Helper.Messaging = new Messaging()