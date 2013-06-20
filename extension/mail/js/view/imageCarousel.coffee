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
    @localCollection = new MeetMikey.Collection.Images()

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
    models: _.invoke(@localCollection.models, 'decorate')
    activeIndex: @activeIndex
    idSuffix: @idSuffix


  getModelIndexInFullCollection: (forceModel) =>
    model = @activeModel
    if forceModel
      model = forceModel
    if ! model
      #console.log 'ERROR: getModelIndexInFullCollection. no activeModel'
      return
    fullCollectionModel = @fullCollection.find (testModel) =>
      testModel.id == model.id
    fullCollectionIndex = @fullCollection.indexOf fullCollectionModel
    fullCollectionIndex

  getLocalImages: =>
    @localCollection.reset []
    fullCollectionIndex = @getModelIndexInFullCollection()
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
      @localCollection.push newModel
      if model.id == @activeModel.id
        @activeIndex = curIndex
        @activeModel = newModel
      curIndex++
      index++

  openImage: (event) =>
    @sanityCheck 'openImage start'
    event.preventDefault()
    cid = $(event.currentTarget).closest('.image-box').attr('data-cid')
    activeModelInFullCollection = @fullCollection.get(cid)
    @localCollection.reset []
    @activeModel = activeModelInFullCollection.clone()
    @localCollection.push @activeModel
    @parentView.openModal()
    @render()
    @getLocalImages()
    @render()
    @activateModel()

    MeetMikey.Helper.trackResourceEvent 'openResource', @activeModel,
      search: !@options.search, currentTab: MeetMikey.Globals.tabState, rollover: false

    @sanityCheck 'openImage end'

  bindCarouselKeys: =>
    @unbindCarouselKeys()
    $(document).on 'keydown', @keyHandler

  unbindCarouselKeys: =>
    $(document).off 'keydown', @keyHandler

  sanityCheck: (where) =>
    localIndex = 0
    previousFullCollectionIndex = -1
    previousModelId = null
    while ( localIndex < @localCollection.length )
      model = @localCollection.at localIndex
      fullCollectionIndex = @getModelIndexInFullCollection model
      if ( previousFullCollectionIndex != -1 )
        matches = ( fullCollectionIndex - previousFullCollectionIndex ) == 1
        if ! matches
          console.log 'sanityCheck warning: ' + where + ': previousFullCollectionIndex: ', previousFullCollectionIndex, ', previousModelId: ', previousModelId, ', current fullCollectionIndex: ', fullCollectionIndex, ', current model.id: ', model.id
          @printFullCollectionsIds()
          @printLocalCollectionsIds()
      previousFullCollectionIndex = fullCollectionIndex
      previousModelId = model.id
      localIndex++

  goLeft: =>
    @sanityCheck 'goLeft start'
    #console.log 'goLeft'
    if @activeIndex > 0
      @activeIndex--
      @activeModel = @localCollection.at @activeIndex
      fullCollectionIndex = @getModelIndexInFullCollection()
      newLowIndex = fullCollectionIndex - @numPreloadImagesEachWay
      if newLowIndex < 0
        newLowIndex = 0
      #console.log 'goLeft: newLowIndex: ', newLowIndex, ', fullCollectionIndexOfActiveModel', fullCollectionIndex, ', activeModel cid: ', @activeModel.cid, ', activeIndex: ', @activeIndex
      if newLowIndex < @lowIndex
        @lowIndex = newLowIndex
        model = @fullCollection.at @lowIndex
        @localCollection.unshift model.clone()
        @render()
      @activateModel()
      @sanityCheck 'goLeft end'

  goRight: =>
    #console.log 'goRight start'
    @sanityCheck 'goRight start'
    if @activeIndex < ( @localCollection.length - 1 )
      @activeIndex++
      @activeModel = @localCollection.at @activeIndex
      fullCollectionIndex = @getModelIndexInFullCollection()
      newHighIndex = fullCollectionIndex + @numPreloadImagesEachWay
      if newHighIndex > ( @fullCollection.length - 1 )
        newHighIndex = ( @fullCollection.length - 1 )
      #console.log 'goRight, activeIndex: ', @activeIndex, ', newHighIndex: ', newHighIndex, ', fullCollectionIndex', fullCollectionIndex, ', fullCollection length: ', @fullCollection.length
      if newHighIndex > @highIndex
        @highIndex = newHighIndex
        model = @fullCollection.at @highIndex
        @localCollection.push model.clone()
        @render()
        if ( @fullCollection.length - @highIndex ) < @bufferToFetchMoreImages
          #console.log 'fetching more...'
          @parentView.fetchMoreImages @numImagesToFetch
        #else
          #console.log 'not fetching more, buffer: ', @fullCollection.length - @highIndex
      @activateModel()
      @sanityCheck 'goRight end'

  printFullCollectionsIds: =>
    index = 0
    console.log 'fullCollection IDs, activeModel id: ', @activeModel?.id, ', fullCollectionIndex: ', @getModelIndexInFullCollection()
    while ( index < @fullCollection.length )
      console.log 'index: ', index, ', id: ', @fullCollection.at(index).id
      index++

  printLocalCollectionsIds: =>
    index = 0
    console.log 'localCollection IDs, activeModel id: ', @activeModel?.id, ', fullCollectionIndex: ', @getModelIndexInFullCollection()
    while ( index < @localCollection.length )
      console.log 'index: ', index, ', id: ', @localCollection.at(index).id
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
        @printLocalCollectionsIds()
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