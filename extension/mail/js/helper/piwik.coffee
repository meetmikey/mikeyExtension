class Piwik

  apiURL: 'https://tools.meetmikey.com/piwik/piwik.php'
  piwik: _paq
  eventFields: ['userId', 'email', 'firstName', 'lastName', 'displayName', 'extensionVersion', 'locale', 'gender', 'userCreatedTimestamp']
  hasSetup: false
  maxIndex: 5

  setup: () =>
    if ! @hasSetup
      @hasSetup = true
      @piwik.push ['setTrackerUrl', @apiURL]
      @piwik.push ['setSiteId', '1']

  setUser: (allProps) =>
    @setup()
    scope = 'visit'
    for i in [1..@maxIndex] by 1
      @_deleteCustomVariable i, scope
    @_setCustomVariable 1, 'userId', allProps.userId, scope
    @_setCustomVariable 2, 'email', allProps.email, scope
    @_setCustomVariable 3, 'displayName', allProps.displayName, scope
    @_setCustomVariable 4, 'extensionVersion', allProps.extensionVersion, scope
    #@_setCustomVariable 4, 'extensionVersion', allProps.extensionVersion, scope
    

  trackEvent: (event, eventProps, allProps) =>
    @setup()
    #console.log 'trackEvent, event: ', event
    scope = 'page'
    for i in [1..@maxIndex] by 1
      @_deleteCustomVariable i, scope
    @_setCustomVariable 1, 'email', allProps['email'], scope if allProps['email']
    i = 2
    _.each eventProps, (value, key) =>
      @_setCustomVariable i, key, value, scope
      i++
    for i in [1..@maxIndex] by 1
      @_getCustomVariable i, scope
    @piwik.push ['trackPageView', event]

  _setCustomVariable: (index, name, value, scope) =>
    @piwik.push ['setCustomVariable', index, name, value, scope]

  _deleteCustomVariable: (index, scope) =>
    @piwik.push ['deleteCustomVariable', index, scope]

  _getCustomVariable: (index, scope) =>
    @piwik.push([ () ->
      customVariable = @getCustomVariable index, scope 
      #console.log 'getCustomVariable, index: ', index, ', scope: ', scope, 'value: ', customVariable
    ])

MeetMikey.Helper.Piwik = new Piwik()