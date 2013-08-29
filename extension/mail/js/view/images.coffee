downloadUrl = chrome.extension.getURL("#{MeetMikey.Constants.imgPath}/sprite.png")

imageTemplate = """
  <div class="image-box" data-cid="{{cid}}">
    <div class="hide-image-x download-tooltip" data-toggle="tooltip" data-animation="false" title="Hide"><div class="close-x">x</div></div>
    {{#if deleting}}

      <div class="undo-delete">This image will no longer appear.<br>Click to undo.</div>
      <div class="image-subbox" style="opacity.1">
    {{else}}
      <div class="undo-delete" style="display:none;">This image will no longer appear.<br>Click to undo.</div>
      <div class="image-subbox">
    {{/if}}
      
      <div class="mm-image-container">
        <img class="mm-image" src="{{image}}"/>
      </div>
     
        <div class="image-filename">
          <a href="#">{{subject}}</a>
        </div>

        <div class="rollover-actions">
          <div class="mm-download-tooltip" data-toggle="tooltip" title="Like">
            <div id="mm-image-like-{{cid}}" class="mm-image-like inbox-icon like{{#if isLiked}}On{{/if}}"></div>
          </div>
          <div class="mm-download-tooltip" data-toggle="tooltip" title="Star">
            <div id="mm-image-favorite-{{cid}}" class="mm-image-favorite inbox-icon favorite{{#if isFavorite}}On{{/if}}"></div>
          </div>
          <div class="mm-download-tooltip" data-toggle="tooltip" title="Open email">
            <div class="list-icon message" style="background-image: url('#{downloadUrl}');"></div>
          </div>
        </div>

        
      </div>
      
    
  </div>
"""

template = """
    <div class="mmCarouselModal modal fade" style="display:none;">
      <div class="mmImageCarousel"></div>
    </div>

    <div class="mmImagesIsotope">
      {{#if models}}
        {{#each models}}
          """ + imageTemplate + """
        {{/each}}
      {{/if}}
    </div>
"""


class MeetMikey.View.Images extends MeetMikey.View.Base
  template: Handlebars.compile(template)
  imageTemplate: Handlebars.compile(imageTemplate)

  pollDelay: MeetMikey.Constants.pollDelay
  hasInitializedIsotope: false
  isotopeTimeInterval: 500
  defaultNumImagesToFetch: 8
  infiniteScrollThreshold: 1000
  fetching: false
  searchQuery: null
  numSearchResultsReceived: 0
  endOfImages: false

  safeFind: MeetMikey.Helper.DOMManager.find

  safeFindEither: MeetMikey.Helper.DOMManager.findEither

  subViews:
    'imageCarousel':
      viewClass: MeetMikey.View.ImageCarousel
      selector: '.mmImageCarousel'
      args: {}

  events:
    'click .mm-image': 'openImage'
    'click .image-filename a': 'openImage'
    'click .message': 'openMessage'
    'click .hide-image-x' : 'markDeleting'
    'click .mm-image-favorite': 'toggleFavoriteEvent'
    'click .mm-image-like': 'toggleLikeEvent'
    'load .mm-image': 'imageLoaded'

  postInitialize: =>
    @on 'showTab', @runIsotope
    #@on 'showTab', @bindScrollHandler
    Backbone.on 'change:tab', @hashChange
    @collection = new MeetMikey.Collection.Images()
    @collection.on 'reset', _.debounce(@render, 50)
    @subViews.imageCarousel.view.setImageCollection @collection
    $(window).off 'hashchange', @hashChange
    $(window).on 'hashchange', @hashChange
    @setupModal()

  setupModal: =>
    @$('.mmCarouselModal').modal
      show: false

  setFetch: (isFetch) =>
    @options.fetch = isFetch
    if isFetch
      MeetMikey.globalEvents.off 'favoriteOrLikeAction', @favoriteOrLikeAction
      MeetMikey.globalEvents.on 'favoriteOrLikeAction', @favoriteOrLikeAction

  favoriteOrLikeAction: =>
    if not @isVisible()
      @initialFetch()

  isSearch: =>
    not @options.fetch

  isModalVisible: =>
    @$('.mmCarouselModal').hasClass 'fade-in'
    
  openModal: =>
    @$('.mmCarouselModal').modal 'show'
    @$('.mmCarouselModal').trigger('mouseover')

  hideModal: =>
    @$('.mmCarouselModal').modal 'hide'

  postRender: =>
    @hasInitializedIsotope = false
    $('.download-tooltip').tooltip placement: 'bottom'
    $('.mm-download-tooltip').tooltip placement: 'top'
    @runIsotope()
    @addImageLoadEvents()

  openImage: (event) =>
    cid = $(event.currentTarget).closest('.image-box').attr('data-cid')
    model = @collection.get(cid)
    if !model.get('deleting')
      @subViews.imageCarousel.view.openImage event
    else
      @unMarkDeleting (event)

  teardown: =>
    @clearTimeout()
    @cachedModels = _.clone @collection.models
    @collection.reset()
    @unbindScrollHandler()
    $(window).off 'hashchange', @hashChange

  initialFetch: =>
    @collection.fetch success: @waitAndPoll if @options.fetch

  restoreFromCache: =>
    @collection.reset @cachedModels
    @endOfImages = false

  getTemplateData: =>
    models: _.invoke @collection.models, 'decorate'
    searchQuery: @searchQuery

  markDeleting: (event) =>
    event.preventDefault()
    cid = $(event.currentTarget).closest('.image-box').attr('data-cid')
    model = @collection.get(cid)
    model.set 'deleting', true
    element = @$('.image-box[data-cid='+model.cid+']')
    imageElement = element.children '.image-subbox'
    imageElement.css('opacity', .1) if imageElement?
    element.children('.undo-delete').show()

    @deleteAfterDelay model.cid
    MeetMikey.Helper.trackResourceEvent 'deleteResource', model,
      search: @searchQuery?, currentTab: MeetMikey.Globals.tabState, rollover: false

  unMarkDeleting: (event) =>
    event.preventDefault()
    cid = $(event.currentTarget).closest('.image-box').attr('data-cid')
    model = @collection.get(cid)

    model.set('deleting', false)
    element = @$('.image-box[data-cid='+model.cid+']')
    imageElement = element.children('.image-subbox')
    imageElement.css('opacity', 1) if imageElement?
    element.children('.undo-delete').hide()

  deleteAfterDelay: (modelCId) =>
    setTimeout =>
      model = @collection.get modelCId
      if model and model.get 'deleting'
        @collection.remove model
        model.delete()
        isotopeItem = @$('.image-box[data-cid='+model.cid+']')
        @$('.mmImagesIsotope').isotope 'remove', isotopeItem
    , MeetMikey.Constants.deleteDelay

  openMessage: (event) =>
    cid = $(event.currentTarget).closest('.image-box').attr('data-cid')
    if ! cid
      cid = $(event.currentTarget).closest('.item').attr('data-cid')
    if ! cid
      return
    model = @collection.get cid
    if ! model
      return
    threadHex = MeetMikey.Helper.decimalToHex( model.get 'gmThreadId' )
    if @searchQuery
      hash = "#search/#{@searchQuery}/#{threadHex}"
    else
      hash = "#inbox/#{threadHex}"

    MeetMikey.Helper.trackResourceEvent 'openMessage', model,
      currentTab: MeetMikey.Globals.tabState, search: !@options.fetch, rollover: false

    window.location = hash

  hashChange: =>
    if @isVisible()
      @runIsotope()
    setTimeout @checkAndBindScrollHandler, 200
    setTimeout @checkAndBindScrollHandler, 1000
    setTimeout @checkAndBindScrollHandler, 2000
    setTimeout @checkAndBindScrollHandler, 4000

  checkAndBindScrollHandler: =>
    if @isVisible()
      @runIsotope()
      @bindScrollHandler()
    else
      @unbindScrollHandler()

  isVisible: =>
    isVisible = @$el.is ':visible'
    isVisible

  $scrollElem: =>
    if MeetMikey.Globals.previewPane
      @$el.parent()
    else
      @safeFindEither(MeetMikey.Constants.Selectors.scrollContainer, MeetMikey.Constants.Selectors.scrollContainer2)

  bindScrollHandler: =>
    @unbindScrollHandler()
    @$scrollElem().on 'scroll', @scrollHandler

  unbindScrollHandler: =>
    @$scrollElem().off 'scroll', @scrollHandler

  scrollHandler: (event)=>
    @fetchMoreImages() if @nearBottom()

  nearBottom: =>
    $scrollElem = @$scrollElem()
    elHeight = @$el.parent().parent().height()
    nearBottom = $scrollElem.scrollTop() + $scrollElem.height() > ( elHeight - @infiniteScrollThreshold )
    nearBottom

  fetchMoreImages: (forceNumToFetch) =>
    if @endOfImages or @fetching
      return
    if @isSearch()
      @getMoreSearchResults()
    else
      numToFetch = @defaultNumImagesToFetch
      if forceNumToFetch
        numToFetch = forceNumToFetch
      @fetching = true
      MeetMikey.Helper.callAPI
        url: 'image'
        data:
          before: @earliestSentDate
          limit: numToFetch
        success: (res) =>
          if _.isEmpty(res)
            @endOfImages = true
          else
            @addImagesFromFetchResponse res

  getMoreSearchResults: =>
    @fetching = true
    MeetMikey.Helper.callAPI
      url: "searchImages"
      type: 'GET'
      data:
        query: @searchQuery
        fromIndex: @numSearchResultsReceived
      success: (res) =>
        if _.isEmpty(res)
          @endOfImages = true
        else
          @addImagesFromFetchResponse res
          @numSearchResultsReceived += res.length
      failure: ->
        @logger.info 'search failed'

  addImagesFromFetchResponse: (res, atBeginning) =>
    newModels = []
    _.each res, (imageData) =>
      if not atBeginning and imageData.sentDate and ( ! @earliestSentDate or ( imageData.sentDate < @earliestSentDate ) )
        @earliestSentDate = imageData.sentDate
      newModel = new MeetMikey.Model.Image imageData
      isDupe = false
      @collection.each (oldModel) =>
        if oldModel.get('hash') == newModel.get('hash')
          isDupe = true
      if not isDupe
        if atBeginning
          @collection.unshift newModel
        else
          @collection.push newModel
        newModels.push newModel
    @addNewImageModelTemplates newModels, atBeginning
    @delegateEvents()
    @fetching = false

  addNewImageModelTemplates: (models, atBeginning) =>
    if not models or not models.length
      return
    decoratedModels = _.invoke(models, 'decorate')
    html = ''
    _.each decoratedModels, (decoratedModel) =>
      html += @imageTemplate(decoratedModel)
    items = $(html)
    if atBeginning
      @$('.mmImagesIsotope').prepend( items )
    else
      @$('.mmImagesIsotope').isotope 'insert', items
    @addImageLoadEvents()
    @runIsotope()

  addImageLoadEvents: =>
    @$el.find('.mm-image').off 'load'
    @$el.find('.mm-image').on 'load', _.debounce @imageLoaded, 200

  imageLoaded: (event) =>
    @runIsotope()
    @initializeIsotope()
    @$('.mmImagesIsotope').isotope( 'reloadItems' ).isotope({ sortBy: 'original-order' })

  initializeIsotope:() =>
    if @hasInitializedIsotope
      return
    @$('.mmImagesIsotope').isotope
      filter: '*'
      animationEngine: 'css'
    @hasInitializedIsotope = true

  runIsotope: =>
    @initializeIsotope()
    @$('.mmImagesIsotope').isotope( 'reloadItems' ).isotope({ sortBy: 'original-order' })

  setResults: (models, query) =>
    @searchQuery = query
    @endOfImages = false
    @numSearchResultsReceived = models.length
    @collection.reset models, sort: false

  waitAndPoll: =>
    @timeoutId = setTimeout @poll, @pollDelay

  clearTimeout: =>
    clearTimeout @timeoutId if @timeoutId

  poll: =>
    data = if MeetMikey.globalUser.get('onboarding') or @collection.length < MeetMikey.Constants.imagePaginationSize
      {}
    else
      after: @collection.latestSentDate()

    MeetMikey.Helper.callAPI
        url: 'image'
        data: data
        success: (res) =>
          @addImagesFromFetchResponse res, true
          @waitAndPoll()
        error: @waitAndPoll

  toggleFavoriteEvent: (event) =>
    event.preventDefault()
    cid = $(event.currentTarget).closest('.image-box').attr('data-cid')
    model = @collection.get(cid)
    elementId = '#mm-image-favorite-' + model.cid
    MeetMikey.Helper.FavoriteAndLike.toggleFavorite model, elementId, 'tab'

  toggleLikeEvent: (event) =>
    event.preventDefault()
    cid = $(event.currentTarget).closest('.image-box').attr('data-cid')
    model = @collection.get(cid)
    elementId = '#mm-image-like-' + model.cid
    MeetMikey.Helper.FavoriteAndLike.toggleLike model, elementId, 'tab'