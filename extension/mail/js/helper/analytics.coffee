class Analytics
  inCorrectEnv: MeetMikey.Constants.env is 'production'
  logger: MeetMikey.Helper.Logger

  mixpanel: MeetMikey.Helper.Mixpanel
  mixpanelOff: MeetMikey.Constants.mixpanelOff

  piwik: MeetMikey.Helper.Piwik
  piwikOff: MeetMikey.Constants.piwikOff

  googleAnalytics: MeetMikey.Helper.GoogleAnalytics
  googleAnalyticsOff: MeetMikey.Constants.googleAnalyticsOff

  globalProps:
    extensionVersion: MeetMikey.Constants.extensionVersion
    multipleInbox: MeetMikey.Globals.multipleInbox

  userProps: {}

  setUser: (user) =>
    @userProps = _.pick user.attributes, 'email', 'firstName', 'lastName', 'displayName'
    @userProps.userId = user.id
    @userProps.userCreatedTimestamp = user.get('timestamp')

    #update these, in case they weren't set earlier
    @globalProps.extensionVersion = MeetMikey.Constants.extensionVersion
    @globalProps.multipleInbox = MeetMikey.Globals.multipleInbox

    allProps = @_buildAllProps()

    return unless @inCorrectEnv && MeetMikey.Helper.isRealUser()
    @mixpanel.setUser allProps unless @mixpanelOff
    @piwik.setUser allProps unless @piwikOff
    @googleAnalytics.setUser allProps unless @googleAnalyticsOff

  trackEvent: (event, eventProps) =>
    #@logger.info 'trackEvent:', event, eventProps
    return unless @inCorrectEnv && MeetMikey.Helper.isRealUser()
    eventProps = eventProps || {}
    allProps = @_buildAllProps eventProps
    @mixpanel.trackEvent event, eventProps, allProps unless @mixpanelOff
    @piwik.trackEvent event, eventProps, allProps unless @piwikOff
    @googleAnalytics.trackEvent event, eventProps, allProps unless @googleAnalyticsOff

  _buildAllProps: (eventProps) =>
    eventProps = _.clone( eventProps || {} )
    allProps = _.extend eventProps, @globalProps
    allProps = _.extend allProps, @userProps
    allProps

MeetMikey.Helper.Analytics = new Analytics()