downloadUrl = chrome.extension.getURL("#{MeetMikey.Constants.imgPath}/sprite.png")
template = """
  {{#unless models}}

  {{else}}

    <div id="mmCarouselModal-{{idSuffix}} class="modal fade">
      <div id="mmCarousel-{{idSuffix}}" class="carousel slide">
        
        <!-- Carousel items -->
        <div class="carousel-inner">
          {{#each models}}
            {{#if @index}}
              <div class="item" data-cid="{{cid}}">
            {{else}}
              <div class="active item" data-cid="{{cid}}">
            {{/if}}
              <img class="max-image" src="{{url}}"/>
              <div class="image-info">
                <div class="image-sender">{{from}}</div>
                <div class="image-subject">{{subject}}</div>

                {{#if ../searchQuery}}
                

                     <a href="#search/{{../../searchQuery}}/{{msgHex}}" class="open-message" data-dismiss="modal">
                      <div class="list-icon" style="float:right; display:inline-blocks;">
                        <div class="list-icon" style="background-image: url('#{downloadUrl}');">
                        </div>
                     </div>
                    </a>
                {{else}}
              
                    <a href="#inbox/{{msgHex}}" class="open-message" data-dismiss="modal">
                      <div class="list-icon" style="float:right; display:inline-blocks;">
                        <div class="list-icon" style="background-image: url('#{downloadUrl}');">
                        </div>
                     </div>
                    </a>
                {{/if}}
               
              </div>
            </div>
          {{/each}}
        </div>

        <!-- Carousel nav -->
        <div class="carousel-control left" href="#mmCarousel-{{idSuffix}}" style="cursor:pointer;" data-slide="prev">&lsaquo;</div>
        <div class="carousel-control right" href="#mmCarousel-{{idSuffix}}" style="cursor:pointer;" data-slide="next">&rsaquo;</div>
      </div>
    </div>

    <div id="mmImagesIsotope-{{idSuffix}}">
    {{#each models}}
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
              <!-- <a href="#">Forward</a> -->

               {{#if ../searchQuery}}
                  <a href="#search/{{../../searchQuery}}/{{msgHex}}" class="open-message">View email thread</a>
                {{else}}
                  <a href="#inbox/{{msgHex}}" class="open-message">
                    <div class="list-icon image-box-tooltip" data-toggle="tooltip" title="View email">
                      <div class="list-icon" style="background-image: url('#{downloadUrl}');">
                      </div>
                    </div>
                  </a>
            {{/if}}
            </div>
          </div>
        </div>
      </div>
    {{/each}}
    </div>
  {{/unless}}
"""

class MeetMikey.View.Images extends MeetMikey.View.Base
  template: Handlebars.compile(template)

  pollDelay: MeetMikey.Constants.pollDelay
  fetching: false

  safeFind: MeetMikey.Helper.DOMManager.find

  events:
    'click .mm-image': 'openImage'
    'click .image-filename a': 'openImage'
    'click .open-message': 'openMessage'
    'click .hide-image-x' : 'markDeleting'
    'click .undo-delete' : 'unMarkDeleting'

  postInitialize: =>
    @on 'showTab', @initIsotope
    @on 'showTab', @bindScrollHandler
    Backbone.on 'change:tab', @unbindScrollHandler
    @collection = new MeetMikey.Collection.Images()
    @collection.on 'reset add', _.debounce(@render, MeetMikey.Constants.paginationSize)
    @collection.on 'remove', @render
    @idSuffix = Math.random().toString().substring(2,8)

  postRender: =>
    $('.mm-download-tooltip').tooltip placement: 'bottom'
    $('.image-box-tooltip').tooltip placement: 'top'
    if MeetMikey.Globals.tabState == 'images'
      @initIsotope()
    $('#mmCarousel-' + @idSuffix).carousel
      interval: false
    $('#mmCarouselModal-' + @idSuffix).modal
      show: false
    $('#mmCarouselModal-' + @idSuffix).on 'shown', () =>
      @carouselVisible = true
    $('#mmCarouselModal-' + @idSuffix).on 'hidden', () =>
      @carouselVisible = false
    @bindCarouselKeys()

  teardown: =>
    @clearTimeout()
    @cachedModels = _.clone @collection.models
    @collection.reset()
    @unbindScrollHandler()

  initialFetch: =>
    @collection.fetch success: @waitAndPoll if @options.fetch

  restoreFromCache: =>
    @collection.reset(@cachedModels)

  getTemplateData: =>
    models: _.invoke(@collection.models, 'decorate')
    idSuffix: @idSuffix
    searchQuery: @searchQuery

  markDeleting: (event) =>
    event.preventDefault()
    cid = $(event.currentTarget).closest('.image-box').attr('data-cid')
    model = @collection.get(cid)
    model.set('deleting', true)
    element = $('.image-box[data-cid='+model.cid+']')
    imageElement = element.children('.image-subbox')
    imageElement.css('opacity', .1) if imageElement?
    element.children('.undo-delete').show()

    @deleteAfterDelay (model.cid)
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
      model = @collection.get(modelId)
      if model.get('deleting')
        @collection.remove(model)
        model.delete()
    , MeetMikey.Constants.deleteDelay

  openImage: (event) =>
    event.preventDefault()
    cid = $(event.currentTarget).closest('.image-box').attr('data-cid')
    model = @collection.get(cid)
    index = @collection.indexOf model
    $('#mmCarouselModal-' + @idSuffix).modal 'show'
    $('#mmCarousel-' + @idSuffix).carousel index
    $('#mmCarouselModal-' + @idSuffix).trigger('mouseover')
    $('#mmCarousel-' + @idSuffix).trigger('mouseover')

    MeetMikey.Helper.trackResourceEvent 'openResource', model,
      search: !@options.search, currentTab: MeetMikey.Globals.tabState, rollover: false

  bindCarouselKeys: =>
    $(document).keydown (e) =>
      if e.keyCode == 37
        if @carouselVisible
          $('#mmCarousel-' + @idSuffix).carousel 'prev'
          return false
      if e.keyCode == 39
        if @carouselVisible
          $('#mmCarousel-' + @idSuffix).carousel 'next'
          return false
      if e.keyCode == 27
        if @carouselVisible
          $('#mmCarouselModal-' + @idSuffix).modal 'hide'
          return false

  openMessage: (event) =>
    cid = $(event.currentTarget).closest('.image-box').attr('data-cid')
    if ! cid
      cid = $(event.currentTarget).closest('.item').attr('data-cid')
    model = @collection.get(cid)
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

  unbindScrollHandler: => @$scrollElem().off 'scroll', @scrollHandler

  scrollHandler: (event)=>
    @fetchMoreImages() if not @fetching and not @endOfImages and @nearBottom()

  nearBottom: =>
    $scrollElem = @$scrollElem()
    $scrollElem.scrollTop() + $scrollElem.height() > ( @$el.height() - 1000 )

  fetchMoreImages: =>
    @fetching = true
    @collection.fetch
      silent: true
      update: true
      remove: false
      data:
        before: @collection.last()?.get('sentDate')
        limit: 5
      success: @fetchSuccess

  fetchSuccess: (collection, response) =>
    @fetching = false
    @endOfImages = true if _.isEmpty(response)
    @appendNewImageModelTemplates response
    $('#mmImagesIsotope-' + @idSuffix).isotope('reloadItems')
    @initIsotope()
    @delegateEvents()

  appendNewImageModelTemplates: (response) =>
    ids = _.pluck response, '_id'
    models = _.map ids, (id) => @collection.get(id)
    decoratedModels = _.invoke(models, 'decorate')
    @$el.append @template(models: decoratedModels)

  runIsotope: =>
    if @isotopeHasInitialized
      $('#mmImagesIsotope-' + @idSuffix).isotope('reloadItems')
    $('#mmImagesIsotope-' + @idSuffix).isotope
      filter: '*'
      animationEngine: 'css'
    @isotopeHasInitialized = true

  checkAndRunIsotope: =>
    if @areImagesLoaded
      # @logger.info 'images loaded, clearing isotope interval', @isotopeInterval
      clearInterval @isotopeInterval
      @isotopeInterval = null
    else
      @runIsotope()

  initIsotope: =>
    # @logger.info 'init isotope'
    @areImagesLoaded = false
    if ! @isotopeInterval
      @isotopeInterval = setInterval @checkAndRunIsotope, 200
    @$el.imagesLoaded =>
      @areImagesLoaded = true
      # @logger.info 'images loaded, isotoping one last time'
      @runIsotope()

  setResults: (models, query) =>
    @on 'showTab', @initIsotope
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
