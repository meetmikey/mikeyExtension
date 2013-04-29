class Mixpanel
  apiUrl: 'https://api.mixpanel.com'

  inCorrectEnv: MeetMikey.Constants.env is 'production'
  token: MeetMikey.Constants.mixpanelId
  extensionVersion: MeetMikey.Constants.extensionVersion

  userId: null

  logger: MeetMikey.Helper.Logger

  # TODO: write wrapper for engage endpoint, add distinct_id support with identify
  setUser: (user) =>
    eventObj = @_buildUserObj user
    $.ajax
      url: "#{@apiUrl}/engage"
      data: {data: @encodeB64(eventObj)}

  trackEvent: (event, props) =>
    obj = @_buildEventObj event, props
    $.ajax
      url: "#{@apiUrl}/track"
      data:
        data: @encodeB64(obj)
        ip: 1

  encodeB64: (obj) ->
    # btoa dies on utf-8 strings, escape/unescape fixes
    str = JSON.stringify obj
    window.btoa unescape encodeURIComponent str

  _buildEventObj: (event, props)=>
    metaData = _.extend @userProps ? {},
      token: @token, time: Date.now(), distinct_id: @userId, extensionVersion: @extensionVersion
    properties = _.extend props, metaData
    {event, properties}

  _buildUserObj: (user) =>
    attrs = user.attributes

    $token: @token
    $distinct_id: @userId
    $set:
      $email: attrs.email
      $first_name: attrs.firstName
      $last_name: attrs.lastName
      $extension_version: @extensionVersion
      $multiple_inbox: MeetMikey.Globals.multipleInbox


MeetMikey.Helper.Mixpanel = new Mixpanel()