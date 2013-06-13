downloadUrl = chrome.extension.getURL("#{MeetMikey.Constants.imgPath}/sprite.png")
template = """
  {{#unless models}}

  {{else}}

    <div id="mmCarouselModal" class="modal fade">
      <div id="mmCarousel" class="carousel slide">
        
        <!-- Carousel items -->
        <div class="carousel-inner">
          {{#each models}}
            {{#if @index}}
              <div class="item" data-cid="{{cid}}">
            {{else}}
              <div class="active item" data-cid="{{cid}}">
            {{/if}}
              <img class="mm-image" src="{{url}}"/>
              <div class="carousel-caption">
                {{#if ../searchQuery}}
                  <a href="#search/{{../../searchQuery}}/{{msgHex}}" class="open-message" data-dismiss="modal">View email thread</a>
                {{else}}
                  <a href="#inbox/{{msgHex}}" class="open-message" data-dismiss="modal">View email thread</a>
                {{/if}}
                from: {{from}}
                subject: {{subject}}
              </div>
            </div>
          {{/each}}
        </div>

        <!-- Carousel nav -->
        <a class="carousel-control left" href="#mmCarousel" data-slide="prev">&lsaquo;</a>
        <a class="carousel-control right" href="#mmCarousel" data-slide="next">&rsaquo;</a>
      </div>
    </div>

    <div id="mmImagesIsotope">
    {{#each models}}
      <div class="image-box" data-cid="{{cid}}">
        <div class="hide-image-x"><div class="close-x">x</div></div>
        <img class="mm-image" src="{{image}}" />
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
                  <div class="list-icon mm-download-tooltip" data-toggle="tooltip" title="View email">
                    <div class="list-icon" style="background-image: url('#{downloadUrl}');">
                    </div>
                  </div>
                </a>
          {{/if}}
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
    'click .hide-image-x' : 'markDeletingEvent'

  postInitialize: =>
    @on 'showTab', @initIsotope
    @on 'showTab', @bindScrollHandler
    Backbone.on 'change:tab', @unbindScrollHandler
    @collection = new MeetMikey.Collection.Images()
    @collection.on 'reset add', _.debounce(@render, MeetMikey.Constants.paginationSize)
    @collection.on 'remove', @render

  postRender: =>
    @$('.mm-download-tooltip').tooltip placement: 'bottom'
    if MeetMikey.Globals.tabState == 'images'
      @initIsotope()
    $('.carousel').carousel
      interval: false
    $('#mmCarouselModal').modal
      show: false

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
    searchQuery: @searchQuery

  markDeletingEvent: (event) =>
    event.preventDefault()
    cid = $(event.currentTarget).closest('.image-box').attr('data-cid')
    model = @collection.get(cid)
    model.set('deleting', true)
    element = $('.image-box[data-cid='+model.cid+']')
    element.css('opacity', .1) if element?

    @deleteAfterDelay (model.cid)
    MeetMikey.Helper.trackResourceEvent 'deleteResource', model,
      search: @searchQuery?, currentTab: MeetMikey.Globals.tabState, rollover: false

  unMarkDeleting: (event) =>
    model.set('deleting', false)
    element = $('.image-box[data-cid='+model.cid+']')
    element.css('opacity', 1) if element?

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
    $('#mmCarouselModal').modal 'show'
    $('.carousel').carousel index

    MeetMikey.Helper.trackResourceEvent 'openResource', model,
      search: !@options.search, currentTab: MeetMikey.Globals.tabState, rollover: false


  openMessage: (event) =>
    cid = $(event.currentTarget).closest('.image-box').attr('data-cid')
    if ! cid
      cid = $(event.currentTarget).closest('.item').attr('data-cid')
    model = @collection.get(cid)

    MeetMikey.Helper.trackResourceEvent 'openMessage', model,
      currentTab: MeetMikey.Globals.tabState, search: !@options.fetch, rollover: false

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
    $('#mmImagesIsotope').isotope('reloadItems')
    @initIsotope()
    @delegateEvents()

  appendNewImageModelTemplates: (response) =>
    ids = _.pluck response, '_id'
    models = _.map ids, (id) => @collection.get(id)
    decoratedModels = _.invoke(models, 'decorate')
    @$el.append @template(models: decoratedModels)

  runIsotope: =>
    if @isotopeHasInitialized
      $('#mmImagesIsotope').isotope('reloadItems')
    $('#mmImagesIsotope').isotope
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
