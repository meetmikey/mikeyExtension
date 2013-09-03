class Messaging

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

MeetMikey.Helper.Messaging = new Messaging()