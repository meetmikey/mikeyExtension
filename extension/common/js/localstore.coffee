class MeetMikey.Helper.LocalStore
  _instance = undefined

  @store: () ->
    _instance ?= new LocalStore

  @get: (key) =>
    @store().get key

  @set: (key, value) =>
    @store().set key, value

  @remove: (key) =>
    @store().remove key

  @clear: =>
    @store().clear()

class LocalStore
  constructor: (@args) ->
    @store = window.localStorage

  supportsLocalStorage: ->
    typeof window.localStorage isnt 'undefined'

  get: (key) =>
    JSON.parse @store.getItem(key)

  set: (key, value) =>
    @store.setItem key, JSON.stringify(value)

  remove: (key) =>
    @store.removeItem key

  clear: =>
    @store.clear()
