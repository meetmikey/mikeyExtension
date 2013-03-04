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
    MeetMikey.Helper.LocalStore.set @userKey(), data

  getUserInfo: =>
    MeetMikey.Helper.LocalStore.get @userKey()

  authorize: (callback) =>
    data = @getUserInfo()
    if data?.refreshToken?
      @refresh data, callback
    else
      @openAuthWindow callback

  authorized: =>
    @getUserInfo()?

  checkUser: (callback) =>
    data = @getUserInfo()
    return callback null unless data?.refreshToken?

    MeetMikey.Helper.callAPI
      url: 'user'
      type: 'GET'
      data:
        refreshToken: data.refreshToken
        userEmail: data.email
      success: (res) =>
        @storeUserInfo res
        callback res
      error: (err) =>
        callback null if err.status is 401



  openAuthWindow: (callback) =>
    handleMessage = (e) =>
      event = e.originalEvent
      return unless event.origin is MeetMikey.Settings.APIUrl
      $(window).off 'message', handleMessage
      userObject = JSON.parse event.data
      if @isUserEmail userObject.email
        @storeUserInfo userObject
        callback userObject
      else
        @authFail()

    $(window).on 'message', handleMessage
    window.open MeetMikey.Settings.APIUrl + '/auth/google'

  refresh: (callback) =>
    data = @getUserInfo()
    return callback null unless data?.refreshToken?

    MeetMikey.Helper.callAPI
      url: "auth/refresh"
      type: 'POST'
      data:
        refreshToken: data.refreshToken
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
