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

  openAuthWindow: (callback) =>
    handleMessage = (e) =>
      event = e.originalEvent
      return unless event.origin is 'https://local.meetmikey.com'
      $(window).off 'message', handleMessage
      userObject = JSON.parse event.data
      if @isUserEmail userObject.email
        @storeUserInfo userObject
        callback userObject
      else
        @authFail()

    $(window).on 'message', handleMessage
    window.open MeetMikey.Settings.APIUrl + '/auth/google'


  refresh: (data, callback) =>
    $.ajax
      url: "#{ MeetMikey.Settings.APIUrl }/auth/refresh"
      type: 'POST'
      data:
        refreshToken: data.refreshToken
        email: data.email
      success: (res) =>
        if @isUserEmail res.email
          callback res
        else
          @openAuthWindow callback
      error: =>
        @openAuthWindow callback

  authFail: =>


MeetMikey.Helper.OAuth = new OAuth()
