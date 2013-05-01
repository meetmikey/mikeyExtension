class Analytics
  inCorrectEnv: MeetMikey.Constants.env is 'production'
  logger: MeetMikey.Helper.Logger

  mixpanel: MeetMikey.Helper.Mixpanel
  mixpanelOff: MeetMikey.Constants.mixpanelOff

  piwik: MeetMikey.Helper.Piwik
  piwikOff: MeetMikey.Constants.piwikOff

  globalProps:
    extensionVersion: MeetMikey.Constants.extensionVersion
    multipleInbox: MeetMikey.Globals.multipleInbox

  userProps: {}

  setUser: (user) =>
    @userProps = _.pick user.attributes, 'email', 'firstName', 'lastName', 'displayName'
    @userProps.userId = user.id
    #return unless @inCorrectEnv
    @mixpanel.setUser  @userProps unless @mixpanelOff
    @piwik.setUser  @userProps unless @piwikOff

  trackEvent: (event, eventProps) =>
    #@logger.info 'trackEvent:', event, eventProps
    #return unless @inCorrectEnv && MeetMikey.Helper.isRealUser()
    allProps = @_buildAllProps eventProps
    @mixpanel.trackEvent event, allProps unless @mixpanelOff
    @piwik.trackEvent event, allProps unless @piwikOff

  _buildAllProps: (eventProps) =>
    allProps = if eventProps? then _.clone(eventProps) else {}
    allProps = _.extend eventProps, @globalProps
    allProps = _.extend allProps, @userProps
    allProps

MeetMikey.Helper.Analytics = new Analytics()