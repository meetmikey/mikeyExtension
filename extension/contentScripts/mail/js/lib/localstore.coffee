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
    raw = @store.getItem(@getKey key)
    try #temporary to accomodate a snafu with setting the beta key
      val = JSON.parse raw
      return val
    catch e
      @logger.info 'local storage get exception'
      return raw

  set: (key, value) =>
    @store.setItem @getKey(key), JSON.stringify(value)

  remove: (key) =>
    @store.removeItem @getKey(key)

  clear: =>
    @store.clear()

  logger: MeetMikey.Helper.Logger

MeetMikey.Helper.LocalStore = new LocalStore()
