class MeetMikey.Collection.Base extends Backbone.Collection
  logger: MeetMikey.Helper.Logger

  compareBy: {}
  sortKey: '_id'
  sortOrder: 'asc'

  toggleSortOrder: =>
    if @sortOrder is 'asc'
      @sortOrder = 'desc'
    else
      @sortOrder = 'asc'

  sortByField: (field) =>
    if @sortKey is field
      @toggleSortOrder()
    else
      @sortOrder = 'asc'
      @sortKey = field
    @sort()

  comparator: (model1, model2) =>
    key = @sortKey
    value1 = if @compareBy[key]? then @compareBy[key](model1) else model1.get(key)
    value2 = if @compareBy[key]? then @compareBy[key](model2) else model2.get(key)

    return 0 if value1 is value2

    if @sortOrder is 'asc'
      if value1 < value2 then -1 else 1
    else if @sortOrder is 'desc'
      if value1 > value2 then -1 else 1
    else 0

  fetch: (opts) ->
    opts.cache = false
    return super opts unless MeetMikey.globalUser?

    MeetMikey.Helper.callAPI

    opts ?= {}
    apiData = MeetMikey.Helper.getBasicAPIData()
    if opts.data?
      _.extend opts.data, apiData
    else
      opts.data = apiData
    super opts

  earliestSentDate: =>
    _.min @map (model) -> new Date(model.get 'sentDate').getTime()

  latestSentDate: =>
    _.max @map (model) -> new Date(model.get 'sentDate').getTime()
