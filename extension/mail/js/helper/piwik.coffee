class Piwik

  apiUrl: 'https://tools.meetmikey.com/piwik/'
  extensionVersion: MeetMikey.Constants.extensionVersion
  multipleInbox: MeetMikey.Globals.multipleInbox
  userId: null
  logger: MeetMikey.Helper.Logger
  @piwik = _paq || []

  setup: () =>
    @piwik.push ['trackPageView']
    #@piwik.push ['enableLinkTracking']
    @piwik.push ['setTrackerUrl', @apiURL+'piwik.php']
    @piwik.push ['setSiteId', '1']

  setUser: (user) =>
    @_setCustomVariable 1, 'userId', userId
    @_setCustomVariable 2, 'email', user.email
    @_setCustomVariable 3, 'firstName', user.firstName
    @_setCustomVariable 4, 'lastName', user.lastName
    @_setCustomVariable 5, 'displayName', user.displayName
    @_setCustomVariable 6, 'extensionVersion', @extensionVersion
    @_setCustomVariable 7, 'multipleInbox', @multipleInbox

  trackEvent: (event, props) =>
    # @logger.info 'tracking event:', event, @_buildObj(event,props), @inCorrectEnv
    props = if props? then _.clone(props) else {}
    @piwik.push ['trackPageView']

  _isRealUser: =>
    ! _.contains(MeetMikey.Constants.MikeyTeamUserIds, @userId)

  _buildObj: (event, props)=>
    metaData = _.extend @userProps ? {},
      token: @token, time: Date.now(), distinct_id: @userId, extensionVersion: @extensionVersion
    properties = _.extend props, metaData
    {event, properties}

  _track: (event, props) =>
    obj = @_buildObj event, props
    #TODO: track...

  _setCustomVariable: (index, name, value) =>
    @piwik.push ['setCustomVariable', index, name, value, 'visit']

MeetMikey.Helper.Piwik = new Piwik()