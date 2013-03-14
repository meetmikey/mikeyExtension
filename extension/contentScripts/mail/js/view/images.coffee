template = """
  {{#unless models}}
    Hold up, finding your images, boss.
  {{else}}
    {{#each models}}
      <div class="image-box" data-cid="{{cid}}">
        <div>
          <img class="mm-image" src="{{image}}" />
          <div class="image-filename">{{filename}}</div>
        </div>
        <div class="image-footer">
          <a href="#inbox/{{msgHex}}">View email thread</a>
          <div class="image-footer-actions">
            <a href="#">Forward</a>
            <a href="{{image}}">Download</a>
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
    #console.log 'checkAndRunIsotope'
    if @areImagesLoaded
      #console.log 'images loaded, clearing interval'
      clearInterval @isotopeInterval
    else
      @runIsotope()

  initIsotope: =>
    #console.log 'initIsotope'
    @areImagesLoaded = false
    @isotopeInterval = setInterval @checkAndRunIsotope, 200
    @$el.imagesLoaded =>
      @areImagesLoaded = true
      #console.log 'images loaded, isotoping one last time'
      @runIsotope()

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
