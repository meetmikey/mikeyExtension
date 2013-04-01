class OAuth
  getUserEmail: ->
    $('#gbmpdv .gbps2').text()

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

  doNotAsk: =>
    @storeUserInfo email: @getUserEmail(), ignoreAccount: true

  trackAuthEvent: (user) =>
    MeetMikey.Helper.Mixpanel.trackEvent 'authorized', user

  checkUser: (callback) =>
    data = @getUserInfo()
    return if data?.ignoreAccount
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


MeetMikey.Helper.OAuth = new OAuth()
