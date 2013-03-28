template = """
  {{#unless models}}

  {{else}}
    {{#each models}}
      <div class="image-box" data-cid="{{cid}}">
        <img class="mm-image" src="{{image}}" />
        <div class="image-text">
          {{#if ../searchQuery}}
            <a href="#search/{{../../searchQuery}}/{{msgHex}}" class="open-message">View email thread</a>
          {{else}}
            <a href="#inbox/{{msgHex}}" class="open-message">View email thread</a>
          {{/if}}
          <div class="rollover-actions">
            <!-- <a href="#">Forward</a> -->
            <a href="{{image}}">Open</a>
          </div>
        </div>
      </div>
    {{/each}}
    <div style="clear: both;"></div>
  {{/unless}}
"""

class MeetMikey.View.Images extends MeetMikey.View.Base
  template: Handlebars.compile(template)

  pollDelay: 1000*45
  fetching: false

  events:
    'click .mm-image': 'openImage'
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

  getTemplateData: =>
    models: _.invoke(@collection.models, 'decorate')
    searchQuery: @searchQuery

  openImage: (event) =>
    cid = $(event.currentTarget).closest('.image-box').attr('data-cid')
    model = @collection.get(cid)
    url = model.get 'image'

    MeetMikey.Helper.trackResourceEvent 'openResource', model,
      search: !@options.search, currentTab: MeetMikey.Globals.tabState, rollover: false

    window.open url

  openMessage: (event) =>
    cid = $(event.currentTarget).closest('.image-box').attr('data-cid')
    model = @collection.get(cid)

    MeetMikey.Helper.trackResourceEvent 'openMessage', model,
      currentTab: MeetMikey.Globals.tabState, search: !@options.fetch, rollover: false

  $scrollElem: => $('[id=":rp"]')
  bindScrollHandler: => @$scrollElem().on 'scroll', @scrollHandler if @options.fetch
  unbindScrollHandler: => @$scrollElem().off 'scroll', @scrollHandler

  scrollHandler: (event)=>
    @fetchMoreImages() if not @fetching and not @endOfImages and @nearBottom()

  nearBottom: =>
    $scrollElem = @$scrollElem()
    $scrollElem.scrollTop() + $scrollElem.height() > @$el.height()

  fetchMoreImages: =>
    console.log 'go and fetch some images!'
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
    @endOfImages = true if _.isEmpty(@response)
    @render()
    @$el.isotope('reloadItems')
    @initIsotope()

  runIsotope: =>
    console.log 'isotoping'
    @$el.isotope
      filter: '*'
      animationOptions:
        duration: 750
        easing: 'linear'
        queue: false

  checkAndRunIsotope: =>
    console.log 'checkAndRunIsotope'
    if @areImagesLoaded
      console.log 'images loaded, clearing interval'
      clearInterval @isotopeInterval
    else
      @runIsotope()

  initIsotope: =>
    console.log 'initIsotope'
    @areImagesLoaded = false
    @isotopeInterval = setInterval @checkAndRunIsotope, 200
    @$el.imagesLoaded =>
      @areImagesLoaded = true
      console.log 'images loaded, isotoping one last time'
      @runIsotope()

  setResults: (models, query) =>
    @searchQuery = query
    @collection.reset models, sort: false

  waitAndPoll: =>
    setTimeout @poll, @pollDelay

  poll: =>
    console.log 'images are polling'
    @collection.fetch
      update: true
      remove: false
      data:
        after: @collection.first()?.get('sentDate')
      success: @waitAndPoll
      error: @waitAndPoll
