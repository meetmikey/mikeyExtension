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
