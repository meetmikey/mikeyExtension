class Mixpanel
  apiUrl: 'https://api.mixpanel.com'

  inCorrectEnv: MeetMikey.Settings.env is 'production'
  token: MeetMikey.Settings.mixpanelId

  userId: null

  # TODO: write wrapper for engage endpoint, add distinct_id support with identify
  setUser: (user) =>
    return unless @inCorrectEnv
    @userId = user.id
    @_engage user

  trackEvent: (event, props) =>
    console.log 'tracking event:', event, @inCorrectEnv
    return unless @inCorrectEnv
    props = if props? then _.clone(props) else {}
    props = _.extend props, @props
    @_track event, props

  encodeB64: (obj) ->
    # btoa dies on utf-8 strings, escape/unescape fixes
    str = JSON.stringify obj
    window.btoa unescape encodeURIComponent str

  _buildObj: (event, props)=>
    properties = _.extend props, {token: @token, time: Date.now(), distinct_id: @userId}
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

  _engage: (user) =>
    obj = @_buildUserObj user
    $.ajax
      url: "#{@apiUrl}/engage"
      data: {data: @encodeB64(obj)}


MeetMikey.Helper.Mixpanel = new Mixpanel()
