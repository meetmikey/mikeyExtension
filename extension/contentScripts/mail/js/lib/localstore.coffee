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

MeetMikey.Helper.LocalStore = new LocalStore()
