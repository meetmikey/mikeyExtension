class LocalStore
  constructor: (@args) ->
    @store = window.localStorage

  supportsLocalStorage: ->
    typeof window.localStorage isnt 'undefined'

  get: (key) =>
    raw = @store.getItem(key)
    try #temporary to accomodate a snafu with setting the beta key
      val = JSON.parse raw
      return val
    catch e
      console.log 'local storage get exception'
      return raw

  set: (key, value) =>
    @store.setItem key, JSON.stringify(value)

  remove: (key) =>
    @store.removeItem key

  clear: =>
    @store.clear()

MeetMikey.Helper.LocalStore = new LocalStore()
