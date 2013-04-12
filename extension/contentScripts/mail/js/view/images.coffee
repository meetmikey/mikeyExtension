downloadUrl = chrome.extension.getURL("#{MeetMikey.Settings.imgPath}/sprite.png")
template = """
  {{#unless models}}

  {{else}}
    {{#each models}}
      <div class="image-box" data-cid="{{cid}}">
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
  {{/unless}}
"""

class MeetMikey.View.Images extends MeetMikey.View.Base
  template: Handlebars.compile(template)

  pollDelay: MeetMikey.Settings.pollDelay
  fetching: false

  safeFind: MeetMikey.Helper.DOMManager.find

  events:
    'click .mm-image': 'openImage'
    'click .image-filename a': 'openImage'
    'click .open-message': 'openMessage'

  postInitialize: =>
    @once 'showTab', @initIsotope
    @on 'showTab', @bindScrollHandler
    Backbone.on 'change:tab', @unbindScrollHandler
    @collection = new MeetMikey.Collection.Images()
    @collection.on 'reset add', _.debounce(@render, 50)
    if @options.fetch
      @collection.fetch success: @waitAndPoll

  postRender: =>
      @$('.mm-download-tooltip').tooltip placement: 'bottom'

  teardown: =>
    @cachedModels = _.clone @collection.models
    @collection.reset()

  restoreFromCache: =>
    @collection.reset(@cachedModels)

  getTemplateData: =>
    models: _.invoke(@collection.models, 'decorate')
    searchQuery: @searchQuery

  openImage: (event) =>
    event.preventDefault()
    cid = $(event.currentTarget).closest('.image-box').attr('data-cid')
    model = @collection.get(cid)
    url = model.getUrl()

    MeetMikey.Helper.trackResourceEvent 'openResource', model,
      search: !@options.search, currentTab: MeetMikey.Globals.tabState, rollover: false

    window.open url

  openMessage: (event) =>
    cid = $(event.currentTarget).closest('.image-box').attr('data-cid')
    model = @collection.get(cid)

    MeetMikey.Helper.trackResourceEvent 'openMessage', model,
      currentTab: MeetMikey.Globals.tabState, search: !@options.fetch, rollover: false

  $scrollElem: => @safeFind(MeetMikey.Settings.Selectors.scrollContainer)
  bindScrollHandler: => @$scrollElem().on 'scroll', @scrollHandler if @options.fetch
  unbindScrollHandler: => @$scrollElem().off 'scroll', @scrollHandler

  scrollHandler: (event)=>
    @fetchMoreImages() if not @fetching and not @endOfImages and @nearBottom()

  nearBottom: =>
    $scrollElem = @$scrollElem()
    $scrollElem.scrollTop() + $scrollElem.height() > ( @$el.height() - 1000 )

  fetchMoreImages: =>
    #console.log 'go and fetch some images!'
    @fetching = true
    @collection.fetch
      silent: true
      update: true
      remove: false
      data:
        before: @collection.last()?.get('sentDate')
      success: @fetchSuccess

  fetchSuccess: (collection, response) =>
    @fetching = false
    @endOfImages = true if _.isEmpty(response)
    @appendNewImageModelTemplates response
    @$el.isotope('reloadItems')
    @initIsotope()
    @delegateEvents()

  appendNewImageModelTemplates: (response) =>
    ids = _.pluck response, '_id'
    models = _.map ids, (id) => @collection.get(id)
    decoratedModels = _.invoke(models, 'decorate')
    @$el.append @template(models: decoratedModels)

  runIsotope: =>
    #console.log 'isotoping'
    @$el.isotope
      filter: '*'
      animationEngine: 'css'

  checkAndRunIsotope: =>
    #console.log 'checkAndRunIsotope'
    if @areImagesLoaded
      console.log 'images loaded, clearing isotope interval', @isotopeInterval
      clearInterval @isotopeInterval
      @isotopeInterval = null;
    else
      @runIsotope()

  initIsotope: =>
    #console.log 'initIsotope'
    @areImagesLoaded = false
    if ! @isotopeInterval
      @isotopeInterval = setInterval @checkAndRunIsotope, 200
    @$el.imagesLoaded =>
      @areImagesLoaded = true
      #console.log 'images loaded, isotoping one last time'
      @runIsotope()

  setResults: (models, query) =>
    @searchQuery = query
    @collection.reset models, sort: false

  waitAndPoll: =>
    setTimeout @poll, @pollDelay

  poll: =>
    data = if MeetMikey.globalUser.get('onboarding')
      {}
    else
      after: @collection.first()?.get('sentDate')

    console.log 'images are polling'
    @collection.fetch
      update: true
      remove: false
      data: data
      success: @waitAndPoll
      error: @waitAndPoll
