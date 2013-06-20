downloadUrl = chrome.extension.getURL("#{MeetMikey.Constants.imgPath}/sprite.png")

imageTemplate = """
  <div class="image-box" data-cid="{{cid}}">
    <div class="hide-image-x mm-download-tooltip" data-toggle="tooltip" title="Hide this image"><div class="close-x">x</div></div>
    {{#if deleting}}

      <div class="undo-delete">This image will no longer appear.<br>Click here to undo.</div>
      <div class="image-subbox" style="opacity.1">
    {{else}}
      <div class="undo-delete" style="display:none;">This image will no longer appear.<br>Click here to undo.</div>
      <div class="image-subbox">
    {{/if}}
      <img class="mm-image" src="{{image}}"/>
      <div class="image-text">
        <div class="image-filename">
          <a href="#">{{filename}}&nbsp;</a>
        </div>

        <div class="rollover-actions">
          <a href="#inbox/{{msgHex}}" class="open-message">
            <div class="list-icon image-box-tooltip" data-toggle="tooltip" title="View email">
              <div class="list-icon" style="background-image: url('#{downloadUrl}');">
              </div>
            </div>
          </a>
        </div>
      </div>
    </div>
  </div>
"""

template = """
    <div class="mmCarouselModal modal fade">
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
  isotopeTimeInterval: 200
  defaultNumImagesToFetch: 8
  infiniteScrollThreshold: 1000
  fetching: false

  safeFind: MeetMikey.Helper.DOMManager.find

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
    'click .undo-delete' : 'unMarkDeleting'

  postInitialize: =>
    @on 'showTab', @isotopeUntilImagesLoaded
    @on 'showTab', @bindScrollHandler
    Backbone.on 'change:tab', @unbindScrollHandler
    @collection = new MeetMikey.Collection.Images()
    @collection.on 'reset', _.debounce(@render, MeetMikey.Constants.paginationSize)
    @subViews.imageCarousel.view.setImageCollection @collection
    @setupModal()

  setupModal: =>
    @$('.mmCarouselModal').modal
      show: false

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
    @subViews.imageCarousel.view.openImage event

  teardown: =>
    @clearTimeout()
    @cachedModels = _.clone @collection.models
    @collection.reset()
    @unbindScrollHandler()

  initialFetch: =>
    @collection.fetch success: @waitAndPoll if @options.fetch

  restoreFromCache: =>
    @collection.reset @cachedModels

  getTemplateData: =>
    models: _.invoke @collection.models, 'decorate'
    searchQuery: @searchQuery

  markDeleting: (event) =>
    event.preventDefault()
    cid = $(event.currentTarget).closest('.image-box').attr('data-cid')
    model = @collection.get(cid)
    model.set 'deleting', true
    element = $('.image-box[data-cid='+model.cid+']')
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
    element = $('.image-box[data-cid='+model.cid+']')
    imageElement = element.children('.image-subbox')
    imageElement.css('opacity', 1) if imageElement?
    element.children('.undo-delete').hide()

  deleteAfterDelay: (modelId) =>
    setTimeout =>
      model = @collection.get modelId
      if model.get 'deleting'
        @collection.remove model
        model.delete()
    , MeetMikey.Constants.deleteDelay

  openMessage: (event) =>
    cid = $(event.currentTarget).closest('.image-box').attr('data-cid')
    if ! cid
      cid = $(event.currentTarget).closest('.item').attr('data-cid')
    model = @collection.get cid
    msgHex = model.get 'gmMsgHex'
    if @options.fetch
      hash = "#inbox/#{msgHex}"
    else
      hash = "#search/#{@searchQuery}/#{msgHex}"

    MeetMikey.Helper.trackResourceEvent 'openMessage', model,
      currentTab: MeetMikey.Globals.tabState, search: !@options.fetch, rollover: false

    window.location = hash

  $scrollElem: =>
    if MeetMikey.Globals.previewPane
      @$el.parent()
    else
      @safeFind(MeetMikey.Constants.Selectors.scrollContainer)

  bindScrollHandler: =>
    @$scrollElem().on 'scroll', () =>
      if @options.fetch
        @scrollHandler()

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
    numToFetch = @defaultNumImagesToFetch
    if forceNumToFetch
      numToFetch = forceNumToFetch
    if not @endOfImages and not @fetching
      @fetching = true
      MeetMikey.Helper.callAPI
        url: '/image'
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

  addImagesFromFetchResponse: (res) =>
    _.each res, (imageData) =>
      newModel = new MeetMikey.Model.Image imageData
      @collection.push newModel
    @fetchSuccess res

  fetchSuccess: (response) =>
    @fetching = false
    @endOfImages = true if _.isEmpty(response)
    @appendNewImageModelTemplates response
    @delegateEvents()

  appendNewImageModelTemplates: (response) =>
    ids = _.pluck response, '_id'
    models = _.map ids, (id) => @collection.get(id)
    decoratedModels = _.invoke(models, 'decorate')
    html = ''
    _.each decoratedModels, (decoratedModel) =>
      html += @imageTemplate(decoratedModel)
    items = $(html)
    @$('.mmImagesIsotope').isotope 'insert', items

  runIsotope: =>
    console.log 'runIsotope'
    if ! @hasInitializedIsotope
      console.log 'initializing isotope'
      @$('.mmImagesIsotope').isotope
        filter: '*'
        animationEngine: 'css'
      @hasInitializedIsotope = true
    @$('.mmImagesIsotope').isotope 'reloadItems'

  checkImagesLoadedAndRunIsotope: =>
    if @areImagesLoaded
      # @logger.info 'images loaded, clearing isotope interval', @isotopeInterval
      clearInterval @isotopeInterval
      @isotopeInterval = null
    else
      @runIsotope()

  isotopeUntilImagesLoaded: =>
    # @logger.info 'isotopeUntilImagesLoaded'
    if @isotopeInterval
      return
    @areImagesLoaded = false
    if ! @isotopeInterval
      @isotopeInterval = setInterval @checkImagesLoadedAndRunIsotope, @isotopeTimeInterval
    @$el.imagesLoaded =>
      @areImagesLoaded = true
      # @logger.info 'images loaded, isotoping one last time'
      @runIsotope()

  setResults: (models, query) =>
    @on 'showTab', @isotopeUntilImagesLoaded
    @isotopeUntilImagesLoaded()
    @searchQuery = query
    @collection.reset models, sort: false

  waitAndPoll: =>
    @timeoutId = setTimeout @poll, @pollDelay

  clearTimeout: =>
    clearTimeout @timeoutId if @timeoutId

  poll: =>
    data = if MeetMikey.globalUser.get('onboarding') or @collection.length < MeetMikey.Constants.paginationSize
      {}
    else
      after: @collection.latestSentDate()

    @collection.fetch
      update: true
      remove: false
      data: data
      success: @waitAndPoll
      error: @waitAndPoll
