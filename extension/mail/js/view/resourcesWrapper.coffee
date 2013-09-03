class MeetMikey.View.ResourcesWrapper extends MeetMikey.View.Base

  isSearch: =>
    if not @options
      return false
    isSearch = false
    if not @options.fetch
      isSearch = true
    isSearch

  getTemplateData: =>
    object = {}
    object.isSearch = @isSearch()
    object

  initialFetch: =>
    @getNonFavoriteSubview().initialFetch()
    if @getFavoriteSubview()
      @getFavoriteSubview().initialFetch()

  restoreFromCache: () =>
    @getNonFavoriteSubview().restoreFromCache()
    if @getFavoriteSubview()
      @getFavoriteSubview().restoreFromCache()

  setResults: (models, query) =>
    @getNonFavoriteSubview().setResults models, query
    if @getFavoriteSubview()
      @getFavoriteSubview().setResults models, query

  getCount: =>
    count = @getNonFavoriteSubview().collection.length
    if @getFavoriteSubview()
      count += @getFavoriteSubview().collection.length
    count

  postInitialize: =>
    @getNonFavoriteSubview().collection.on 'reset add remove', () =>
      @trigger 'updateTabCount', @getCount()
    @getNonFavoriteSubview().setFetch @options.fetch
    if @getFavoriteSubview()
      @getFavoriteSubview().collection.on 'reset add remove', () =>
        @trigger 'updateTabCount', @getCount()
      @getFavoriteSubview().setFetch @options.fetch