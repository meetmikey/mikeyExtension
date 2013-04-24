class MeetMikey.Collection.Base extends Backbone.Collection
  logger: MeetMikey.Helper.Logger

  fetch: (opts) ->
    opts.cache = false
    return super opts unless MeetMikey.globalUser?

    opts ?= {}
    apiData =
      userEmail: MeetMikey.globalUser.get('email')
      asymHash: MeetMikey.globalUser.get('asymHash')
      extensionVersion: MeetMikey.Constants.extensionVersion
    if opts.data?
      _.extend opts.data, apiData
    else
      opts.data = apiData
    super opts
