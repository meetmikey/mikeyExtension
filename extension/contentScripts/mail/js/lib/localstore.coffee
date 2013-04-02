class LocalStore
  constructor: (@args) ->
    @store = window.localStorage

  supportsLocalStorage: ->
    typeof window.localStorage isnt 'undefined'

  getEnv: -> MeetMikey.Settings.env

  getKey: (key) =>
    env = @getEnv()
    if env is 'production' then key
    else "#{env}-#{key}"

  get: (key) =>
    JSON.parse @store.getItem(@getKey(key))

  set: (key, value) =>
    @store.setItem @getKey(key), JSON.stringify(value)

  remove: (key) =>
    @store.removeItem @getKey(key)

  clear: =>
    @store.clear()

MeetMikey.Helper.LocalStore = new LocalStore()
