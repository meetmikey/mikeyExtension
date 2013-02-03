class MeetMikey.Helper.OAuth
  _instance = undefined

  @oAuth: ->
    _instance ?= new OAuth

  @authorize: (callback) =>
    @oAuth().authorize(callback)


class OAuth
  storeUserInfo: (data) ->
  getUserInfo: ->

  authorize: (callback) ->
    callback()
