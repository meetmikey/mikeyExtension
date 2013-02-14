class MeetMikey.Collection.Base extends Backbone.Collection
  fetch: (opts) ->
    return super opts unless MeetMikey.globalUser?

    opts ?= {}
    apiData = userEmail: MeetMikey.globalUser.get('email')
    if opts.data?
      _.extend opts.data, apiData
    else
      opts.data = apiData
    super opts
