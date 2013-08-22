downloadUrl = chrome.extension.getURL("#{MeetMikey.Constants.imgPath}/sprite.png")

imageTemplate = """
  <div class="image-box" data-cid="{{cid}}">
    <div class="hide-image-x mm-download-tooltip" data-toggle="tooltip" data-animation="false" title="Hide"><div class="close-x">x</div></div>
    {{#if deleting}}

      <div class="undo-delete">This image will no longer appear.<br>Click to undo.</div>
      <div class="image-subbox" style="opacity.1">
    {{else}}
      <div class="undo-delete" style="display:none;">This image will no longer appear.<br>Click to undo.</div>
      <div class="image-subbox">
    {{/if}}
      <img class="mm-image" src="{{image}}"/>
     
        <div class="image-filename">
          <a href="#">{{filename}}&nbsp;</a>
        </div>

        <div class="rollover-actions">
          <div class="mm-download-tooltip" data-toggle="tooltip" title="Like">
            <div id="mm-image-like-{{cid}}" class="mm-image-like inbox-icon like{{#if isLiked}}On{{/if}}"></div>
          </div>
          <div class="mm-download-tooltip" data-toggle="tooltip" title="Star">
            <div id="mm-image-favorite-{{cid}}" class="mm-image-favorite inbox-icon favorite{{#if isFavorite}}On{{/if}}"></div>
          </div>
          <div class="mm-download-tooltip" data-toggle="tooltip" title="Open email">
            <div class="list-icon open-message" style="background-image: url('#{downloadUrl}');"></div>
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
    'click .open-message': 'openMessage'
    'click .hide-image-x' : 'markDeleting'
    'click .mm-image-favorite': 'toggleFavoriteEvent'
    'click .mm-image-like': 'toggleLikeEvent'

  postInitialize: =>
    @on 'showTab', @isotopeUntilImagesLoaded
    #@on 'showTab', @bindScrollHandler
    Backbone.on 'change:tab', @hashChange
    @collection = new MeetMikey.Collection.Images()
    @collection.on 'reset', _.debounce(@render, MeetMikey.Constants.imagePaginationSize)
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
      MeetMikey.globalEvents.off 'favoriteOrLikeAction', @initialFetch
      MeetMikey.globalEvents.on 'favoriteOrLikeAction', @initialFetch

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
    $('.mm-download-tooltip').tooltip placement: 'bottom'
    $('.image-box-tooltip').tooltip placement: 'top'
    if MeetMikey.Globals.tabState == 'images'
      @isotopeUntilImagesLoaded()

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

  deleteAfterDelay: (modelId) =>
    setTimeout =>
      model = @collection.get modelId
      if model.get 'deleting'
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
    console.log 'bindScrollHandler'
    @unbindScrollHandler()
    @$scrollElem().on 'scroll', @scrollHandler

  unbindScrollHandler: =>
    console.log 'unbindScrollHandler'
    @$scrollElem().off 'scroll', @scrollHandler

  scrollHandler: (event)=>
    console.log 'scrollHandler'
    @fetchMoreImages() if @nearBottom()

  nearBottom: =>
    $scrollElem = @$scrollElem()
    elHeight = @$el.parent().parent().height()
    nearBottom = $scrollElem.scrollTop() + $scrollElem.height() > ( elHeight - @infiniteScrollThreshold )
    console.log 'nearBottom(), nearBottom: ', nearBottom
    nearBottom

  fetchMoreImages: (forceNumToFetch) =>
    console.log 'fetchMoreImages'
    if not @endOfImages and not @fetching
      if @options.fetch
        numToFetch = @defaultNumImagesToFetch
        if forceNumToFetch
          numToFetch = forceNumToFetch
        @fetching = true
        MeetMikey.Helper.callAPI
          url: 'image'
          data:
            userEmail: MeetMikey.globalUser.get('email')
            asymHash: MeetMikey.globalUser.get('asymHash')
            extensionVersion: MeetMikey.Constants.extensionVersion
            before: @collection.last()?.get('sentDate')
            limit: numToFetch
          success: (res) =>
            @addImagesFromFetchResponse res
          #error: (err) =>
            #console.log 'fetch error: ', err
      else
        @getMoreSearchResults()

  getMoreSearchResults: =>
    @fetching = true
    MeetMikey.Helper.callAPI
      url: "searchImages"
      type: 'GET'
      data:
        query: @searchQuery
        fromIndex: @numSearchResultsReceived
      success: (res) =>
        @addImagesFromFetchResponse res
        @numSearchResultsReceived += res.length
        @isotopeUntilImagesLoaded()
      failure: ->
        @logger.info 'search failed'

  addImagesFromFetchResponse: (res) =>
    @endOfImages = true if _.isEmpty(res)
    newModels = []
    _.each res, (imageData) =>
      newModel = new MeetMikey.Model.Image imageData
      isDupe = false
      @collection.each (oldModel) =>
        if oldModel.get('hash') == newModel.get('hash')
          isDupe = true
      if not isDupe
        @collection.push newModel
        newModels.push newModel
    @appendNewImageModelTemplates newModels
    @delegateEvents()
    @fetching = false

  appendNewImageModelTemplates: (models) =>
    decoratedModels = _.invoke(models, 'decorate')
    html = ''
    _.each decoratedModels, (decoratedModel) =>
      html += @imageTemplate(decoratedModel)
    items = $(html)
    @$('.mmImagesIsotope').isotope 'insert', items

  runIsotope: =>
    if ! @hasInitializedIsotope
      @$('.mmImagesIsotope').isotope
        filter: '*'
        animationEngine: 'css'
      @hasInitializedIsotope = true
    @$('.mmImagesIsotope').isotope 'reLayout'

  isotopeUntilImagesLoaded: =>
    # @logger.info 'isotopeUntilImagesLoaded'
    @runIsotope()
    @$el.imagesLoaded =>
      # @logger.info 'images loaded, isotoping one last time'
      @runIsotope()
      setTimeout @runIsotope, 1000
      setTimeout @runIsotope, 4000

  setResults: (models, query) =>
    @on 'showTab', @isotopeUntilImagesLoaded
    @searchQuery = query
    @endOfImages = false
    @numSearchResultsReceived = models.length
    @collection.reset models, sort: false
    @isotopeUntilImagesLoaded()

  waitAndPoll: =>
    @timeoutId = setTimeout @poll, @pollDelay

  clearTimeout: =>
    clearTimeout @timeoutId if @timeoutId

  poll: =>
    data = if MeetMikey.globalUser.get('onboarding') or @collection.length < MeetMikey.Constants.imagePaginationSize
      {}
    else
      after: @collection.latestSentDate()

    @collection.fetch
      update: true
      remove: false
      data: data
      success: @waitAndPoll
      error: @waitAndPoll

  toggleFavoriteEvent: (event) =>
    event.preventDefault()
    cid = $(event.currentTarget).closest('.image-box').attr('data-cid')
    model = @collection.get(cid)
    @toggleFavorite(model)

  toggleFavorite: (model) =>
    oldIsFavorite = model.get('isFavorite')
    newIsFavorite = true
    if oldIsFavorite
      newIsFavorite = false
    model.set 'isFavorite', newIsFavorite
    @updateModelFavoriteDisplay model
    MeetMikey.Helper.trackResourceInteractionEvent 'resourceFavorite', 'image', newIsFavorite, 'tab'
    model.putIsFavorite newIsFavorite, (response, status) =>
      if status != 'success'
        model.set 'isFavorite', oldIsFavorite
        @updateModelFavoriteDisplay model

  updateModelFavoriteDisplay: (model) =>
    elementId = '#mm-image-favorite-' + model.cid
    @$(elementId).removeClass 'favorite'
    @$(elementId).removeClass 'favoriteOn'
    if model.get 'isFavorite'
      @$(elementId).addClass 'favoriteOn'
    else
      @$(elementId).addClass 'favorite'

  updateModelLikeDisplay: (model) =>
    elementId = '#mm-image-like-' + model.cid
    @$(elementId).removeClass 'like'
    @$(elementId).removeClass 'likeOn'
    if model.get 'isLiked'
      @$(elementId).addClass 'likeOn'
    else
      @$(elementId).addClass 'like'

  toggleLikeEvent: (event) =>
    event.preventDefault()
    cid = $(event.currentTarget).closest('.image-box').attr('data-cid')
    model = @collection.get(cid)
    @toggleLike(model)

  toggleLike: (model) =>
    if not model.get('isLiked')
      MeetMikey.Helper.Messaging.checkLikeInfoMessaging model, (shouldProceed) =>
        if shouldProceed
          model.set 'isLiked', true
          @updateModelLikeDisplay model
          MeetMikey.Helper.trackResourceInteractionEvent 'resourceLike', 'image', true, 'tab'
          model.putIsLiked true, (response, status) =>
            if status != 'success'
              model.set 'isLiked', false
              @updateModelLikeDisplay model
            else if @isSearch()
                MeetMikey.globalEvents.trigger 'favoriteOrLikeAction'