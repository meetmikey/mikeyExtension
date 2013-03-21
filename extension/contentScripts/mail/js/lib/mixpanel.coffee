class Mixpanel
  constructor: ->

  inCorrectEnv: MeetMikey.Settings.env is 'production'

  # TODO: write wrapper for engage endpoint, add distinct_id support with identify
  setUser: (user) =>
    return unless @inCorrectEnv
    userProps = _.pick user.attributes, '_id', 'displayName', 'email'
    mixpanel.identify userProps._id
    mixpanel.people.set userProps

  trackEvent: (event, props) =>
    console.log 'tracking event:', event, @inCorrectEnv
    return unless @inCorrectEnv
    props = if props? then _.clone(props) else {}
    props = _.extend props, @props
    @_track event, props

  encodeB64: (obj) ->
    str = JSON.stringify obj
    window.btoa(unescape(encodeURIComponent( str )))

  _buildObj: (event, props)=>
    properties = _.extend props, {token: MeetMikey.Settings.mixpanelId, time: Date.now()}
    {event, properties}

  _track: (event, props) =>
    obj = @_buildObj event, props
    $.ajax
      url: 'http://api.mixpanel.com/track'
      data:
        data: @encodeB64(obj)
        ip: 1


MeetMikey.Helper.Mixpanel = new Mixpanel()
