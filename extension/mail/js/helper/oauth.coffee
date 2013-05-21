class OAuth
  getUserEmail: ->
    $(MeetMikey.Constants.Selectors.userEmail).text()

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

  trackAuthEvent: (user) =>
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
      @storeUserInfo userObject
      @trackAuthEvent userObject
      if @isUserEmail userObject.email
        callback userObject
      else
        @authFail()

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

  authFail: =>
    # put messaging about authorizing wrong email in here


MeetMikey.Helper.OAuth = new OAuth()
