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
  bufferToFetchMoreImages: 10
  numImagesToFetch: 15

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


  getActiveIndexInFullCollection: =>
    if ! @activeModel
      #console.log 'ERROR: getActiveIndexInFullCollection. no activeModel'
      return
    fullCollectionModel = @fullCollection.find (testModel) =>
      testModel.id == @activeModel.id
    fullCollectionIndex = @fullCollection.indexOf fullCollectionModel
    fullCollectionIndex

  getNearbyImages: =>
    @nearbyImagesCollection.reset []
    fullCollectionIndex = @getActiveIndexInFullCollection()
    @lowIndex = fullCollectionIndex - @numPreloadImagesEachWay
    @highIndex = fullCollectionIndex + @numPreloadImagesEachWay
    if @lowIndex < 0
      @lowIndex = 0
    if @highIndex > ( @fullCollection.length - 1 )
      @highIndex = ( @fullCollection.length - 1 )
    index = @lowIndex
    curIndex = 0
    while ( index <= @highIndex )
      model = @fullCollection.at index
      newModel = model.clone()
      @nearbyImagesCollection.add newModel
      if model.id == @activeModel.id
        @activeIndex = curIndex
        @activeModel = newModel
      curIndex++
      index++

  openImage: (event) =>
    event.preventDefault()
    cid = $(event.currentTarget).closest('.image-box').attr('data-cid')
    activeModelInFullCollection = @fullCollection.get(cid)
    @nearbyImagesCollection.reset []
    @activeModel = activeModelInFullCollection.clone()
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
    #console.log 'goLeft'
    if @activeIndex > 0
      @activeIndex--
      @activeModel = @nearbyImagesCollection.at @activeIndex
      fullCollectionIndex = @getActiveIndexInFullCollection()
      newLowIndex = fullCollectionIndex - @numPreloadImagesEachWay
      if newLowIndex < 0
        newLowIndex = 0
      #console.log 'goLeft: newLowIndex: ', newLowIndex, ', fullCollectionIndexOfActiveModel', fullCollectionIndex, ', activeModel cid: ', @activeModel.cid, ', activeIndex: ', @activeIndex
      if newLowIndex < @lowIndex
        @lowIndex = newLowIndex
        model = @fullCollection.at @lowIndex
        @nearbyImagesCollection.unshift model.clone()
        @render()
      @activateModel()

  goRight: =>
    #console.log 'goRight'
    if @activeIndex < ( @nearbyImagesCollection.length - 1 )
      @activeIndex++
      @activeModel = @nearbyImagesCollection.at @activeIndex
      fullCollectionIndex = @getActiveIndexInFullCollection()
      newHighIndex = fullCollectionIndex + @numPreloadImagesEachWay
      if newHighIndex > ( @fullCollection.length - 1 )
        newHighIndex = ( @fullCollection.length - 1 )
      #console.log 'goRight, activeIndex: ', @activeIndex, ', newHighIndex: ', newHighIndex, ', fullCollectionIndex', fullCollectionIndex, ', fullCollection length: ', @fullCollection.length
      if newHighIndex > @highIndex
        @highIndex = newHighIndex
        model = @fullCollection.at @highIndex
        @nearbyImagesCollection.add model.clone()
        @render()
        if ( @fullCollection.length - @highIndex ) < @bufferToFetchMoreImages
          #console.log 'fetching more...'
          @parentView.fetchMoreImages @numImagesToFetch
        else
          #console.log 'not fetching more, buffer: ', @fullCollection.length - @highIndex
      @activateModel()

  printFullCollectionsIds: =>
    index = 0
    console.log 'fullCollection IDs, activeModel id: ', @activeModel?.id, ', fullCollectionIndex: ', @getActiveIndexInFullCollection()
    while ( index < @fullCollection.length )
      console.log 'index: ', index, ', id: ', @fullCollection.at(index).id
      index++

  keyHandler: (e) =>
    #console.log 'keyHandler, keyCode: ', e.keyCode
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
    if e.keyCode == 80
      if @parentView.isModalVisible()
        @printFullCollectionsIds()
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