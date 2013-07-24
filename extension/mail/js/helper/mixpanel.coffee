class Mixpanel
  apiUrl: 'https://api.mixpanel.com'
  token: MeetMikey.Constants.mixpanelId
  eventFields: ['userId', 'email', 'firstName', 'lastName', 'displayName', 'distinct_id', 'extensionVersion', 'token', 'locale', 'gender', 'userCreatedTimestamp']

  setUser: (allProps) =>
    userObj = @_buildUserObj allProps
    $.ajax
      url: "#{@apiUrl}/engage"
      data:
        data: MeetMikey.Helper.encodeB64(userObj)

  trackEvent: (event, eventProps, allProps) =>
    eventObj = @_buildEventObj event, eventProps, allProps
    $.ajax
      url: "#{@apiUrl}/track"
      data:
        data: MeetMikey.Helper.encodeB64(eventObj)
        ip: 1
        verbose: 1

  _buildEventObj: (event, eventProps, allProps)=>
    customProps = {
      token: @token
      distinct_id: allProps.userId
    }

    allProps = _.extend _.clone(allProps), customProps
    fields = _.union @eventFields, _.keys eventProps
    eventProps = _.pick allProps, fields

    {
      event
      , properties: eventProps
    }

  _buildUserObj: (allProps) =>
    $token: @token
    $distinct_id: allProps.userId
    $set:
      $email: allProps.email
      $first_name: allProps.firstName
      $last_name: allProps.lastName
      $extension_version: allProps.extensionVersion
      $multiple_inbox: allProps.multipleInbox
      $created : allProps.timestamp

MeetMikey.Helper.Mixpanel = new Mixpanel()