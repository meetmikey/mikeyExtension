class OAuth
  getUserEmail: ->
    msg = $(MeetMikey.Constants.Selectors.userEmail).text().trim()
    split = msg.split(" ")
    if (split && split.length > 1)
      split.forEach (candidate) =>
        if candidate.indexOf('@') != -1
          msg = candidate
    else
      return null
    
    suffix = '…'
    if (msg.indexOf(suffix) != -1)
      email = msg.substring( 0, msg.length - suffix.length )
    else
      email = msg.substring( 0, msg.length)
    email

  isUserEmail: (email) =>
    email is @getUserEmail()

  userKeyTemplate: (email) ->
    "meetmikey-#{email}"

  userKey: =>
    @userKeyTemplate @getUserEmail()

  storeUserInfo: (data) =>
    MeetMikey.Helper.LocalStore.set @userKeyTemplate(data.email), data

  getUserInfo: =>
    MeetMikey.Helper.LocalStore.get @userKey()

  authorize: (callback) =>
    data = @getUserInfo()
    if data?.asymHash?
      @refresh data, callback
    else
      @openAuthWindow callback

  authorized: =>
    @getUserInfo()?.asymHash?

  toggle: =>
    if @isEnabled() then @disable() else @enable()

  disable: =>
    MeetMikey.Helper.LocalStore.set "#{@userKey()}-disable", true
    MeetMikey.Helper.Setup.mainView?._teardown()
    MeetMikey.Helper.clearCheckTabsInterval()
    @trackDisableEvent()

  enable: =>
    MeetMikey.Helper.LocalStore.set "#{@userKey()}-disable", false
    MeetMikey.Helper.Setup.bootstrap()
    @trackEnableEvent()

  isEnabled: =>
    disabled = MeetMikey.Helper.LocalStore.get "#{@userKey()}-disable"

    not (disabled? and disabled)

  trackEnableEvent: =>
    MeetMikey.Helper.Analytics.trackEvent 'enableExtension',
      userEmail: @getUserEmail()

  trackDisableEvent: =>
    MeetMikey.Helper.Analytics.trackEvent 'disableExtension',
      userEmail: @getUserEmail()

  trackAuthEvent: (userData) =>
    user = new MeetMikey.Model.User userData
    MeetMikey.Helper.Analytics.setUser user
    MeetMikey.Helper.Analytics.trackEvent 'authorized'

  checkUser: (callback) =>
    data = @getUserInfo()
    return unless @isEnabled()
    return callback null unless data?.asymHash?

    MeetMikey.Helper.callAPI
      url: 'user'
      type: 'GET'
      data:
        asymHash: data.asymHash
        userEmail: data.email
      success: (res) =>
        @storeUserInfo res
        callback res
      error: (err) =>
        callback null if err.status is 401

  openAuthWindow: (callback) =>
    handleMessage = (e) =>
      event = e.originalEvent
      return unless event.origin is MeetMikey.Helper.getAPIUrl()
      $(window).off 'message', handleMessage
      userObject = JSON.parse event.data

      if !userObject.error
        @storeUserInfo userObject
        @trackAuthEvent userObject
        if @isUserEmail userObject.email
          callback null, userObject
      else
        callback userObject.message

    $(window).on 'message', handleMessage
    window.open MeetMikey.Helper.getAPIUrl() + '/auth/google?userEmail=' + @getUserEmail()

  refresh: (callback) =>
    data = @getUserInfo()
    return callback null unless data?.asymHash?

    MeetMikey.Helper.callAPI
      url: "auth/refresh"
      type: 'POST'
      data:
        asymHash: data.asymHash
        email: data.email
      success: (res) =>
        if @isUserEmail res.email
          callback res
        else
          callback null
      error: =>
        callback null


MeetMikey.Helper.OAuth = new OAuth()
