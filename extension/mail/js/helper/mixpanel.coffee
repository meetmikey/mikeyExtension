class Mixpanel
  apiUrl: 'https://api.mixpanel.com'
  token: MeetMikey.Constants.mixpanelId
  eventFields: ['userId', 'token', 'time']

  setUser: (allProps) =>
    userObj = @_buildUserObj allProps
    console.log 'user obj:', userObj
    #$.ajax
      #url: "#{@apiUrl}/engage"
      #data: {data: MeetMikey.Helper.encodeB64(userObj)}

  trackEvent: (event, allProps) =>
    eventObj = @_buildEventObj event, allProps
    console.log 'event obj:', eventObj
    #$.ajax
     # url: "#{@apiUrl}/track"
        #data:
        #data: MeetMikey.Helper.encodeB64(eventObj)
        #ip: 1

  _buildEventObj: (event, allProps)=>
    customProps = {
      token: @token
      time: Date.now()
      distinct_id: allProps.userId
    }

    allProps = _.extend allProps, customProps
    eventProps = _.pick allProps, @eventFields

    console.log 'allProps: ', allProps, ', eventFields: ', @eventFields, ', eventProps: ', eventProps

    eventObj: {
      event
      properties: eventProps
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

MeetMikey.Helper.Mixpanel = new Mixpanel()