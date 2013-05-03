class Piwik

  apiURL: 'https://tools.meetmikey.com/piwik/piwik.php'
  piwik: _paq
  eventFields: ['userId', 'email', 'firstName', 'lastName', 'displayName', 'extensionVersion', 'locale', 'gender', 'userCreatedTimestamp']
  hasSetup: false

  setup: () =>
    if ! @hasSetup
      @hasSetup = true
      @piwik.push ['setTrackerUrl', @apiURL]
      @piwik.push ['setSiteId', '1']

  setUser: (allProps) =>
    @setup()
    @_setCustomVariable 1, 'userId', allProps.userId
    @_setCustomVariable 2, 'email', allProps.email
    @_setCustomVariable 3, 'firstName', allProps.firstName
    @_setCustomVariable 4, 'lastName', allProps.lastName
    @_setCustomVariable 5, 'displayName', allProps.displayName
    @_setCustomVariable 6, 'extensionVersion', allProps.extensionVersion
    @_setCustomVariable 7, 'multipleInbox', allProps.multipleInbox

  trackEvent: (event, eventProps, allProps) =>
    @setup()
    fields = _.extend @eventFields, _.keys eventProps
    eventProps = _.pick allProps, fields
    #console.log 'trackEvent, event: ', event
    @piwik.push ['trackPageView', event]

  _setCustomVariable: (index, name, value) =>
    @piwik.push ['setCustomVariable', index, name, value, 'visit']

MeetMikey.Helper.Piwik = new Piwik()