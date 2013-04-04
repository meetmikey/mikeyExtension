template = """
  {{#unless models}}

  {{else}}
    {{#each models}}
      <div class="image-box" data-cid="{{cid}}">
        <img class="mm-image" src="{{image}}" />
        <div class="image-text">
          <div class="image-filename">
            <a href="{{url}}">{{filename}}&nbsp;</a>
          </div>

          <div class="rollover-actions">
            <!-- <a href="#">Forward</a> -->

             {{#if ../searchQuery}}
                <a href="#search/{{../../searchQuery}}/{{msgHex}}" class="open-message">View email thread</a>
              {{else}}
                <a href="#inbox/{{msgHex}}" class="open-message">Email thread</a>
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
    url = model.getUrl()

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
    $scrollElem.scrollTop() + $scrollElem.height() > ( @$el.height() - 1000 )

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
    @endOfImages = true if _.isEmpty(response)
    @appendNewImageModelTemplates response
    @$el.isotope('reloadItems')
    @initIsotope()

  appendNewImageModelTemplates: (response) =>
    models = _.map response, (m) -> new MeetMikey.Model.Attachment(m)
    decoratedModels = _.invoke(models, 'decorate')
    @$el.append @template(models: decoratedModels)

  runIsotope: =>
    console.log 'isotoping'
    @$el.isotope
      filter: '*'
      animationEngine: 'css'

  checkAndRunIsotope: =>
    console.log 'checkAndRunIsotope'
    if @areImagesLoaded
      console.log 'images loaded, clearing interval', @isotopeInterval
      clearInterval @isotopeInterval
      @isotopeInterval = null;
    else
      @runIsotope()

  initIsotope: =>
    console.log 'initIsotope'
    @areImagesLoaded = false
    if ! @isotopeInterval
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
