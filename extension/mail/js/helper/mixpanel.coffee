class Mixpanel
  apiUrl: 'https://api.mixpanel.com'

  inCorrectEnv: MeetMikey.Constants.env is 'production'
  token: MeetMikey.Constants.mixpanelId
  extensionVersion: MeetMikey.Constants.extensionVersion

  userId: null

  logger: MeetMikey.Helper.Logger

  # TODO: write wrapper for engage endpoint, add distinct_id support with identify
  setUser: (user) =>
    @userId = user.id
    @userProps = _.pick user.attributes, 'firstName', 'lastName', 'displayName'
    @userProps.userId = @userId
    return unless @inCorrectEnv
    @_engage user

  trackEvent: (event, props) =>
    # @logger.info 'tracking event:', event, @_buildObj(event,props), @inCorrectEnv
    return unless @inCorrectEnv && @_isRealUser()
    props = if props? then _.clone(props) else {}
    @_track event, props

  encodeB64: (obj) ->
    # btoa dies on utf-8 strings, escape/unescape fixes
    str = JSON.stringify obj
    window.btoa unescape encodeURIComponent str

  _isRealUser: =>
    ! _.contains(MeetMikey.Constants.MikeyTeamUserIds, @userId)

  _buildObj: (event, props)=>
    metaData = _.extend @userProps ? {},
      token: @token, time: Date.now(), distinct_id: @userId, extensionVersion: @extensionVersion
    properties = _.extend props, metaData
    {event, properties}

  _track: (event, props) =>
    obj = @_buildObj event, props
    $.ajax
      url: "#{@apiUrl}/track"
      data:
        data: @encodeB64(obj)
        ip: 1

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

  _engage: (user) =>
    obj = @_buildUserObj user
    $.ajax
      url: "#{@apiUrl}/engage"
      data: {data: @encodeB64(obj)}


MeetMikey.Helper.Mixpanel = new Mixpanel()