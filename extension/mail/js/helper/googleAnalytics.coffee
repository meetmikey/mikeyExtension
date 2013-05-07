class GoogleAnalytics

  apiURL: 'https://tools.meetmikey.com/piwik/piwik.php'
  piwik: _paq
  eventFields: ['userId', 'email', 'firstName', 'lastName', 'displayName', 'extensionVersion', 'locale', 'gender', 'userCreatedTimestamp']
  hasSetup: false

  setup: () =>
    if ! @hasSetup
      @hasSetup = true

(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
})(window,document,'script','//www.google-analytics.com/analytics.js','ga');

      ga('create', 'UA-39249462-1');
      ga('send', 'pageview');

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

MeetMikey.Helper.GoogleAnalytics = new GoogleAnalytics()