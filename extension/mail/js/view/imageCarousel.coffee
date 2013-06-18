downloadUrl = chrome.extension.getURL("#{MeetMikey.Constants.imgPath}/sprite.png")
template = """
  <div id="mmCarousel-{{idSuffix}}" class="carousel slide">
    
    <!-- Carousel items -->
    <div class="carousel-inner">
      {{#each models}}
        <div class="item" data-cid="{{cid}}">
        <img class="max-image" src="{{url}}"/>
        <div class="image-info">
          <div class="image-sender">{{from}}</div>
          <div class="image-subject">{{subject}}</div>

          {{#if ../searchQuery}}
            <a href="#search/{{../../searchQuery}}/{{msgHex}}" class="open-message" data-dismiss="modal">
              <div class="list-icon" style="float:right; display:inline-blocks;">
                <div class="list-icon" style="background-image: url('#{downloadUrl}');"></div>
              </div>
            </a>
          {{else}}
            <a href="#inbox/{{msgHex}}" class="open-message" data-dismiss="modal">
              <div class="list-icon" style="float:right; display:inline-blocks;">
                <div class="list-icon" style="background-image: url('#{downloadUrl}');"></div>
              </div>
            </a>
          {{/if}}
         
          </div>
        </div>
      {{/each}}
    </div>

    <!-- Carousel nav -->
    <div class="carousel-control left" style="cursor:pointer;">&lsaquo;</div>
    <div class="carousel-control right" style="cursor:pointer;">&rsaquo;</div>
  </div>
"""

class MeetMikey.View.ImageCarousel extends MeetMikey.View.Base
  template: Handlebars.compile(template)

  carouselVisible: false
  numPreloadImagesEachWay: 4

  events:
    'click .open-message': 'openMessage'
    'click .left': 'goLeft'
    'click .right': 'goRight'

  postInitialize: =>
    @idSuffix = Math.random().toString().substring(2,8)
    @nearbyImagesCollection = new MeetMikey.Collection.Images()

  setImageCollection: (collection) =>
    @fullCollection = collection

  postRender: =>
    $('#mmCarousel-' + @idSuffix).carousel
      interval: false
    @bindCarouselKeys()

  activateModel: =>
    $('.item').removeClass 'active'
    if @activeModel
      cid = @activeModel.cid
      $('.item[data-cid=' + cid + ']').addClass 'active'

  teardown: =>
    @unbindCarouselKeys()

  getTemplateData: =>
    models: _.invoke(@nearbyImagesCollection.models, 'decorate')
    activeIndex: @activeIndex
    idSuffix: @idSuffix

  getNearbyImages: =>
    @nearbyImagesCollection.reset []
    @lowIndex = @modelIndex - @numPreloadImagesEachWay
    @highIndex = @modelIndex + @numPreloadImagesEachWay
    if @lowIndex < 0
      @lowIndex = 0
    if @highIndex > ( @fullCollection.length - 1 )
      @highIndex = ( @fullCollection.length - 1 )
    index = @lowIndex
    curIndex = 0
    while ( index <= @highIndex )
      model = @fullCollection.at index
      @nearbyImagesCollection.add model
      if model._id = @activeModel._id
        @activeIndex = curIndex
      curIndex++
      index++
    @activeIndex = @nearbyImagesCollection.indexOf @activeModel

  openImage: (event) =>
    event.preventDefault()
    cid = $(event.currentTarget).closest('.image-box').attr('data-cid')
    @activeModel = @fullCollection.get(cid)
    @modelIndex = @fullCollection.indexOf @activeModel
    @nearbyImagesCollection.reset []
    @nearbyImagesCollection.add @activeModel
    @parentView.openModal()
    @render()
    @getNearbyImages()
    @render()
    @activateModel()

    MeetMikey.Helper.trackResourceEvent 'openResource', @activeModel,
      search: !@options.search, currentTab: MeetMikey.Globals.tabState, rollover: false

  bindCarouselKeys: =>
    @unbindCarouselKeys()
    $(document).on 'keydown', @keyHandler

  unbindCarouselKeys: =>
    $(document).off 'keydown', @keyHandler

  goLeft: =>
    if @activeIndex > 0
      @activeIndex--
      @activeModel = @nearbyImagesCollection.at @activeIndex
      fullIndex = @fullCollection.indexOf @activeModel
      newLowIndex = fullIndex - @numPreloadImagesEachWay
      if newLowIndex < 0
        newLowIndex = 0
      if newLowIndex < @lowIndex
        @lowIndex = newLowIndex
        model = @fullCollection.at @lowIndex
        @nearbyImagesCollection.unshift model
        @render()
      @activateModel()

  goRight: =>
    if @activeIndex < ( @nearbyImagesCollection.length - 1 )
      @activeIndex++
      @activeModel = @nearbyImagesCollection.at @activeIndex
      fullIndex = @fullCollection.indexOf @activeModel
      newHighIndex = fullIndex + @numPreloadImagesEachWay
      if newHighIndex > ( @fullCollection.length - 1 )
        newHighIndex = ( @fullCollection.length - 1 )
      if newHighIndex > @highIndex
        @highIndex = newHighIndex
        model = @fullCollection.at @highIndex
        @nearbyImagesCollection.add model
        @render()
      @activateModel()

  keyHandler: (e) =>
    if e.keyCode == 37
      if @parentView.isModalVisible()
        @goLeft()
        return false
    if e.keyCode == 39
      if @parentView.isModalVisible()
        @goRight()
        return false
    if e.keyCode == 27
      if @parentView.isModalVisible()
        @parentView.hideModal()
        return false

  openMessage: (event) =>
    cid = $(event.currentTarget).closest('.image-box').attr('data-cid')
    if ! cid
      cid = $(event.currentTarget).closest('.item').attr('data-cid')
    model = @fullCollection.get(cid)
    msgHex = model.get 'gmMsgHex'
    if @options.fetch
      hash = "#inbox/#{msgHex}"
    else
      hash = "#search/#{@searchQuery}/#{msgHex}"

    MeetMikey.Helper.trackResourceEvent 'openMessage', model,
      currentTab: MeetMikey.Globals.tabState, search: !@options.fetch, rollover: false

    window.location = hash