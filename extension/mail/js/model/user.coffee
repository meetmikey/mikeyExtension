class MeetMikey.Model.User extends Backbone.Model
  idAttribute: "_id"

  defaults:
    'onboarding': true

  initialize: ->

  waitAndFetchOnboard: =>
    setTimeout @fetchOnboard, MeetMikey.Constants.pollDelay

  checkOnboard: =>
    if MeetMikey.Helper.LocalStore.get @onboardKey()
      @set 'onboarding', false
    else
      @fetchOnboard()

  checkInvalidToken: =>
    @.get('invalidToken') == true

  getMailProcessedDays: =>
    if @get('minMRProcessedDate')
      currentDate = Date.now()
      minProcessedDate = new Date( @get('minMRProcessedDate') )
      mailProcessedDateDiff = new Date( currentDate - minProcessedDate )
      mailProcessedDays = mailProcessedDateDiff.getTime() / MeetMikey.Constants.msPerDay
      Math.round( mailProcessedDays )
    else
      0

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
    @get('isPremium')

  fetchOnboard: =>
    MeetMikey.Helper.callAPI
      url: 'onboarding'
      type: 'GET'
      error: @waitAndFetchOnboard
      success: (res) =>
        if res.progress is 1
          MeetMikey.Helper.LocalStore.set @onboardKey(), true
          @set 'onboarding', false
        else @waitAndFetchOnboard()

  onboardKey: => "meetmikey-#{@get('email')}-onboarded"

  deleteUser: (callback) =>
    return callback null unless @get ('asymHash')

    MeetMikey.Helper.callAPI
      url: 'user'
      type: 'DELETE'
      data:
        asymHash: @get('asymHash')
        userEmail: @get('email')
      success: (res) =>
        callback res
      error: (err) =>
        callback err