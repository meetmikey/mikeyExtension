downloadUrl = chrome.extension.getURL("#{MeetMikey.Constants.imgPath}/sprite.png")
template = """
  <div class="mmCarousel carousel slide">

    <!-- Carousel items -->
    <div class="carousel-inner">

      {{#each models}}
        <div class="item" data-cid="{{cid}}">
          
          <div class="hide-image-x mm-download-mm-d" data-toggle="tooltip" title="Hide"><div class="close-x">x</div></div>
          <div class="modal-image-box">
            <img class="max-image" src="{{url}}"/>
          </div>

          <div class="image-info">
            <div class="image-sender">{{from}}</div>
            <div class="image-subject">{{subject}}</div>

              <div class="rollover-actions">
                
                <div class="mm-image-carousel-interaction mm-download-tooltip mm-favorite" data-toggle="tooltip" title="Star">
                  <div id="mm-image-carousel-favorite-{{cid}}" class="inbox-icon favorite{{#if isFavorite}}On{{/if}}"></div>
                </div>
                <div class="mm-image-carousel-interaction mm-download-tooltip mm-like" data-toggle="tooltip" title="Like">
                  <div id="mm-image-carousel-like-{{cid}}" class="inbox-icon like{{#if isLiked}}On{{/if}}"></div>
                </div>
                <div class="open-message mm-download-tooltip mm-image-carousel-interaction" data-dismiss="modal" data-toggle="tooltip" title="Open email">
                  <div class="list-icon" style="margin-top: 0px; background-image: url('#{downloadUrl}');"></div>
                </div>
              </div>

              
            </a>
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
  numPreloadImagesEachWay: 5
  maxImagesInLocalCollection: 20
  bufferToFetchMoreImages: 10
  numImagesToFetch: 15
  trimLocalCollection: true

  events:
    'click .open-message': 'openMessage'
    'click .mm-favorite': 'toggleFavoriteEvent'
    'click .mm-like': 'toggleLikeEvent'
    'click .left': 'goLeft'
    'click .right': 'goRight'

  postInitialize: =>
    @localCollection = new MeetMikey.Collection.Images()

  setImageCollection: (collection) =>
    @fullCollection = collection

  postRender: =>
    @$('.mmCarousel').carousel
      interval: false
    @bindCarouselKeys()
    $('.mm-download-tooltip').tooltip placement: 'top'

  activateModel: =>
    $('.item').removeClass 'active'
    if @activeModel
      cid = @activeModel.cid
      $('.item[data-cid=' + cid + ']').addClass 'active'

  teardown: =>
    @unbindCarouselKeys()

  toggleFavoriteEvent: (event) =>
    event.preventDefault()
    cid = $(event.currentTarget).closest('.item').attr('data-cid')
    model = @localCollection.get cid
    elementId = '#mm-image-carousel-favorite-' + model.cid
    MeetMikey.Helper.FavoriteAndLike.toggleFavorite model, elementId, 'imageCarousel', (status) =>
      if status == 'success'
        imageTabModel = @fullCollection.get(model.id)
        imageTabModel.set 'isFavorite', model.get('isFavorite')
        imageTabCId = imageTabModel.cid
        imageTabElementId = '#mm-image-favorite-' + imageTabCId
        MeetMikey.Helper.FavoriteAndLike.updateModelFavoriteDisplay model, imageTabElementId

  toggleLikeEvent: (event) =>
    event.preventDefault()
    cid = $(event.currentTarget).closest('.item').attr('data-cid')
    model = @localCollection.get cid
    elementId = '#mm-image-carousel-like-' + model.cid
    MeetMikey.Helper.FavoriteAndLike.toggleLike model, elementId, 'imageCarousel', (status) =>
      if status == 'success'
        imageTabModel = @fullCollection.get(model.id)
        imageTabModel.set 'isLiked', model.get('isLiked')
        imageTabCId = imageTabModel.cid
        imageTabElementId = '#mm-image-like-' + imageTabCId
        MeetMikey.Helper.FavoriteAndLike.updateModelLikeDisplay model, imageTabElementId

  getTemplateData: =>
    models: _.invoke(@localCollection.models, 'decorate')
    searchQuery: @parentView.searchQuery

  getModelIndexInFullCollection: (forceModel) =>
    model = @activeModel
    if forceModel
      model = forceModel
    if ! model
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
    event.preventDefault()
    cid = $(event.currentTarget).closest('.image-box').attr('data-cid')
    activeModelInFullCollection = @fullCollection.get(cid)
    @activeModel = activeModelInFullCollection.clone()
    @getLocalImages()
    @render()
    @activateModel()
    @parentView.openModal()

    MeetMikey.Helper.trackResourceEvent 'openResource', @activeModel,
      search: !@options.search, currentTab: MeetMikey.Globals.tabState, rollover: false

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
      previousFullCollectionIndex = fullCollectionIndex
      previousModelId = model.id
      localIndex++

  goLeft: =>
    if @activeIndex > 0
      @activeIndex--
      @activeModel = @localCollection.at @activeIndex
      fullCollectionIndex = @getModelIndexInFullCollection()
      newLowIndex = fullCollectionIndex - @numPreloadImagesEachWay
      if newLowIndex < 0
        newLowIndex = 0
      if newLowIndex < @lowIndex
        @lowIndex = newLowIndex
        model = @fullCollection.at @lowIndex
        @localCollection.unshift model.clone()
        @activeIndex++
        if @trimLocalCollection and ( @localCollection.length > @maxImagesInLocalCollection )
          @highIndex--
          @localCollection.pop()
        @render()
      @activateModel()

  goRight: =>
    if @activeIndex < ( @localCollection.length - 1 )
      @activeIndex++
      @activeModel = @localCollection.at @activeIndex
      fullCollectionIndex = @getModelIndexInFullCollection()
      newHighIndex = fullCollectionIndex + @numPreloadImagesEachWay
      if newHighIndex > ( @fullCollection.length - 1 )
        newHighIndex = ( @fullCollection.length - 1 )
      if newHighIndex > @highIndex
        @highIndex = newHighIndex
        model = @fullCollection.at @highIndex
        @localCollection.push model.clone()
        if @trimLocalCollection and ( @localCollection.length > @maxImagesInLocalCollection )
          @localCollection.shift()
          @lowIndex++
          @activeIndex--
        @render()
        if ( @fullCollection.length - @highIndex ) < @bufferToFetchMoreImages
          @parentView.fetchMoreImages @numImagesToFetch
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
    if ! cid
      return
    model = @localCollection.get cid
    if ! model
      return
    threadHex = MeetMikey.Helper.decimalToHex( model.get 'gmThreadId' )
    if @parentView.searchQuery
      hash = "#search/#{@parentView.searchQuery}/#{threadHex}"
    else
      hash = "#inbox/#{threadHex}"

    MeetMikey.Helper.trackResourceEvent 'openMessage', model,
      currentTab: MeetMikey.Globals.tabState, search: !@options.fetch, rollover: false

    window.location = hash