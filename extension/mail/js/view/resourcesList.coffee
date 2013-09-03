class MeetMikey.View.ResourcesList extends MeetMikey.View.Resources

  pollDelay: MeetMikey.Constants.pollDelay
  sectionIsOpen: true
  cidMarkerClass: '.files'

  postInitialize: =>
    @collection = new @collectionClass()
    @rollover = new @rolloverClass collection: @collection, search: !@options.fetch
    
    @collection.on 'reset', @render
    @collection.on 'delete', @markDeleting
    @collection.on 'undoDelete', @unMarkDeleting

    @paginationState = new MeetMikey.Model.PaginationState items: @collection
    @paginationState.on 'change:page', @render
    @subView('pagination').setState @paginationState

    MeetMikey.globalEvents.on 'favoriteOrLikeEvent', @favoriteOrLikeEvent

  postRender: =>
    @rollover.setElement @$('.rollover-container')
    $('.mm-download-tooltip').tooltip placement: 'bottom'
    @setActiveColumn()

  getTemplateData: =>
    sectionHeader = 'Everything'
    if @areFavoritesInView()
      sectionHeader += ' else'
    if @options.isFavorite
      sectionHeader = 'Starred'

    object = {}
    object.models = _.invoke(@getModels(), 'decorate')
    object.sectionHeader = sectionHeader
    object

  teardown: =>
    @clearTimeout()
    @cachedModels = _.clone @collection.models
    @collection.off 'reset', @render
    @collection.reset()
    @collection.on 'reset', @render #Apparently we have to put this back on.  Not sure why teardown took it off, really.

  sectionToggle: (event) =>
    if @sectionIsOpen
      @sectionIsOpen = false
      @$('.sectionContents').hide()
      @$('.section-arrow').removeClass 'active'
      @$('.section-header').removeClass 'active'
    else
      @sectionIsOpen = true
      @$('.sectionContents').show()
      @$('.section-arrow').addClass 'active'
      @$('.section-header').addClass 'active'

  setFetch: (isFetch) =>
    @options.fetch = isFetch
    if @isSearch()
      @subView('pagination').options.render = false
      @subView('pagination').render()

  removeModel: (model) =>
    if not model
      return
    element = @$('.files[data-cid='+model.cid+']')
    element.remove()
    @collection.remove model

  addModel: (model) =>
    if not model
      return

    @collection.add model
    if @collection.length is 1
      @render()
      return

    decoratedModel = model.decorate()
    html = @resourceTemplate decoratedModel

    myIndex = @collection.models.indexOf model
    if myIndex is -1
      return
    if myIndex is ( @collection.length - 1 )
      @$('.resourceModelsStart').append html
    else
      nextModel = @collection.at (myIndex + 1)
      if not nextModel
        return
      @$('.files[data-cid='+nextModel.cid+']').before html

   moveModelToOtherSubview: (model) =>
    if @isSearch()
      return
    @removeModel model
    if model.get('isFavorite')
    	@getFavoriteSubview().addModel model
    else
    	@getNonFavoriteSubview().addModel model

  favoriteOrLikeEvent: (actionType, resourceType, resourceId, value) =>
    if resourceType isnt @resourceType
      return
    model = @collection.get resourceId
    if not model
      return
    if actionType is 'favorite'
      model.set 'isFavorite', value
      if @isSearch()
        elementId = '#mm-resource-favorite-' + model.cid
        MeetMikey.Helper.FavoriteAndLike.updateModelFavoriteDisplay model, elementId
      else
        if @options.isFavorite and value is true
          return
        if not @options.isFavorite and value is false
          return
        @moveModelToOtherSubview model
    else if actionType is 'like'
      model.set 'isLiked', value
      elementId = '#mm-resource-like-' + model.cid
      MeetMikey.Helper.FavoriteAndLike.updateModelLikeDisplay model, elementId

  markDeleting: (model) =>
    model.set('deleting', true)
    element = $('.files[data-cid='+model.cid+']')
    element.children('.mm-undo').show()
    element.children('.mm-file').hide()
    for child in element.children()
      $(child).css('opacity', .1) if not $(child).hasClass('mm-undo')
    @deleteAfterDelay (model.cid)

    MeetMikey.Helper.trackResourceEvent 'deleteResource', model,
      search: @searchQuery?, currentTab: MeetMikey.Globals.tabState, rollover: false

  deleteAfterDelay: (modelCId) =>
    setTimeout =>
      model = @collection.get(modelCId)
      if model and model.get('deleting')
        @removeModel model
        model.delete()
    , MeetMikey.Constants.deleteDelay

  markDeletingEvent: (event) =>
    event.preventDefault()
    model = @getModelFromEvent event
    @markDeleting model
    false

  unMarkDeletingEvent: (event) =>
    event.preventDefault()
    model = @getModelFromEvent event
    @unMarkDeleting model
    false

  unMarkDeleting: (model) =>
    model.set('deleting', false)
    element = $('.files[data-cid='+model.cid+']')
    element.children('.mm-undo').hide()
    element.children('.mm-file').show()
    for child in element.children()
      $(child).css('opacity', 1) if not $(child).hasClass('mm-undo')

  areFavoritesInView: =>
    areFavoritesInView = false
    favoritesSubview = @getFavoriteSubview()
    if favoritesSubview
      models = favoritesSubview.getModels()
      if models and models.length
        areFavoritesInView = true
    areFavoritesInView

  initialFetch: =>
    if @isSearch()
      return
    @collection.fetch
      data:
        isFavorite: @options.isFavorite?
      success: @waitAndPoll

  restoreFromCache: =>
    @collection.reset(@cachedModels)

  getModels: =>
    if @options.fetch
      @paginationState.getPageItems()
    else
      @collection.models

  sortByColumn: (event) =>
    field = $(event.currentTarget).attr('data-mm-field')
    @collection.sortByField(field) if field?
    @render()

  setActiveColumn: =>
    field = @collection.sortKey
    target = @$("th[data-mm-field='#{field}']")
    target.addClass 'active'
    target.find('.sort-carat').addClass 'ascending' if @collection.sortOrder is 'asc'

  setResults: (models, query) =>
    @searchQuery = query
    @rollover.setQuery query
    @collection.reset models, sort: false

  waitAndPoll: =>
    if @options.isFavorite
      return
    if @timeoutId
      return
    @timeoutId = setTimeout () =>
      @timeoutId = null
      @poll()
    , @pollDelay

  clearTimeout: =>
    if @timeoutId
      clearTimeout @timeoutId

  poll: =>
    data = if MeetMikey.globalUser.get('onboarding') or @collection.length < MeetMikey.Constants.paginationSize
      {}
    else
      after: @collection.latestSentDate()

    data.isFavorite = @options.isFavorite?

    fetchURL = null
    if @collection
      fetchURL = @collection.urlSuffix
    if not fetchURL
      return

    MeetMikey.Helper.callAPI
      url: fetchURL
      data: data
      complete: (response, status) =>
        if status is 'success' and response and response.responseText and response.responseText.length
          try
            responseArray = JSON.parse response.responseText
            if responseArray and responseArray.length
              _.each responseArray, (responseObject) =>
                model = new @modelClass responseObject
                @addModel model
          catch error
        @waitAndPoll()

  startRollover: (event) => @rollover.startSpawn event

  delayRollover: (event) => @rollover.delaySpawn event

  cancelRollover: => @rollover.cancelSpawn()

  openResource: (event) =>
    model = @getModelFromEvent event
    if not model
      return
    url = model.getURL()

    MeetMikey.Helper.trackResourceEvent 'openResource', model,
      search: !@options.search, currentTab: MeetMikey.Globals.tabState, rollover: false

    window.open url