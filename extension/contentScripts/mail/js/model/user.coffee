class MeetMikey.Model.User extends Backbone.Model
  idAttribute: "_id"

  defaults:
    'onboarding': true

  initialize: ->
    @checkOnboard()

  waitAndFetchOnboard: =>
    setTimeout @fetchOnboard, MeetMikey.Settings.pollDelay

  checkOnboard: =>
    if MeetMikey.Helper.LocalStore.get('onboarded')
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
          MeetMikey.Helper.LocalStore.set 'onboarded', true
          @set 'onboarding', false
        else @waitAndFetchOnboard()

