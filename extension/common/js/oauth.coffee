class OAuth
  getUserEmail: ->
    $('#gbmpdv .gbps2').text()

  userKeyTemplate: (email) ->
    "meetmikey-#{email}"

  userKey: =>
    @userKeyTemplate @getUserEmail()

  storeUserInfo: (data) =>
    if data.email is @getUserEmail()
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
      if event.origin is 'https://local.meetmikey.com'
        $(window).off 'message', handleMessage
        userObject = JSON.parse event.data
        @storeUserInfo userObject
        callback userObject

    $(window).on 'message', handleMessage
    window.open MeetMikey.Settings.APIUrl + '/auth/google'


  refresh: (data, callback) =>
    $.ajax
      url: "#{ MeetMikey.Settings.APIUrl }/auth/refresh"
      type: 'POST'
      data:
        refreshToken: data.refreshToken
        email: data.email
      success: (res) ->
        callback res
      error: =>
        @openAuthWindow callback

MeetMikey.Helper.OAuth = new OAuth()
