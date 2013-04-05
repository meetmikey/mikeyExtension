class MeetMikey.Model.User extends Backbone.Model
  idAttribute: "_id"

  defaults:
    'onboarding': true

  initialize: ->

  waitAndCheckOnboard: =>
    setTimeout @checkOnboard, MeetMikey.Settings.pollDelay

  checkOnboard: =>
    MeetMikey.Helper.callAPI
      url: 'onboarding'
      type: 'GET'
      error: @waitAndCheckOnboard
      success: (res) =>
        if res.progress is 1
          @set 'onboarding', false
        else @waitAndCheckOnboard()
