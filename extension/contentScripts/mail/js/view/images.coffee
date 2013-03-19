template = """
  {{#unless models}}
   
  {{else}}
    {{#each models}}
      <div class="image-box" data-cid="{{cid}}">
        <img class="mm-image" src="{{image}}" />
        <div class="image-text">
          {{#if ../searchQuery}}
            <a href="#search/{{../../searchQuery}}/{{msgHex}}">View email thread</a>
          {{else}}
            <a href="#inbox/{{msgHex}}">View email thread</a>
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

  events:
    'click .mm-image': 'openImage'

  postInitialize: =>
    @once 'showTab', @initIsotope
    @collection = new MeetMikey.Collection.Images()
    @collection.on 'reset add', _.debounce(@render, 50)
    if @options.fetch
      @collection.fetch success: @waitAndPoll

  postRender: =>

  getTemplateData: =>
    models: _.invoke(@collection.models, 'decorate')
    searchQuery: @searchQuery

  setCollection: (attachments) =>
    images = _.filter attachments.models, (a) -> a.isImage()
    images = _.uniq images, false, (i) ->
      "#{i.get('hash')}_#{i.get('fileSize')}"
    @collection.reset images

  openImage: (event) =>
    cid = $(event.currentTarget).closest('.image-box').attr('data-cid')
    model = @collection.get(cid)
    url = model.get 'image'

    window.open url

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
