class MeetMikey.Model.User extends Backbone.Model
  idAttribute: "_id"

  defaults:
    'onboarding': true

  initialize: ->

  waitAndFetchOnboard: =>
    setTimeout @fetchOnboard, MeetMikey.Constants.onboardCheckPollDelay

  checkOnboard: =>
    if MeetMikey.Helper.LocalStore.get @onboardKey()
      @set 'onboarding', false
    else
      @fetchOnboard()

  checkLikeInfoMessaging: =>
    if MeetMikey.Helper.LocalStore.get @likeInfoMessagingKey()
      return true
    else
      return false

  setLikeInfoMessaging: =>
    MeetMikey.Helper.LocalStore.set @likeInfoMessagingKey(), true

  checkInvalidToken: =>
    @.get('invalidToken') == true

  getDaysLimit: =>
    if @get('isPremium')
      -1
    else if @get('daysLimit')
      @get('daysLimit')
    else
      0

  refreshFromServer: (callback) =>
    MeetMikey.Helper.OAuth.checkUser (userData) =>
      if userData?
        @set userData
      callback() if callback

  getBillingPlan: () =>
    billingPlan = @get('billingPlan')
    if ! billingPlan
      billingPlan = 'free'
    billingPlan

  getMailTotalDays: =>
    if @get('minMailDate')
      currentDate = Date.now()
      minMailDate = new Date( @get('minMailDate') )
      mailTotalDateDiff = new Date( currentDate - minMailDate )
      mailTotalDays = mailTotalDateDiff.getTime() / MeetMikey.Constants.msPerDay
      Math.round( mailTotalDays )
    else
      0

  getMailLimitDays: =>
    if ( @isPremium() )
      -1
    else
      @get('daysLimit')

  isPremium: =>
    if @get('isPremium')
      return true
    else
      return false

  fetchOnboard: =>
    MeetMikey.Helper.callAPI
      url: 'onboarding'
      type: 'GET'
      error: @waitAndFetchOnboard
      success: (res) =>
        if res.progress is 1
          MeetMikey.Helper.LocalStore.set @onboardKey(), true
          @set 'onboarding', false
          @refreshFromServer () =>
            #console.log 'done onboarding, refreshed user'
        else
          @waitAndFetchOnboard()

  onboardKey: => "meetmikey-#{@get('email')}-onboarded"

  likeInfoMessagingKey: => "meetmikey-#{@get('email')}-likeInfoMessaging"

  deleteUser: (callback) =>
    return callback null unless @get ('asymHash')

    MeetMikey.Helper.callAPI
      url: 'user'
      type: 'DELETE'
      success: (res) =>
        callback res
      error: (err) =>
        callback err