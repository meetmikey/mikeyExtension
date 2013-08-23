template = """
  <div class="mmCarouselModal mm-sidebar-carousel modal hide fade">
    <div class="mmCarousel carousel slide">

    <!-- Carousel items -->
    <div class="carousel-inner">
      
      {{#each models}}
        <div class="item" data-cid="{{cid}}">
          <div class="hide-image-x mm-download-tooltip" data-toggle="tooltip" title="Hide"><div class="close-x">x</div></div>
          <div class="modal-image-box">
            <img class="max-image" src="{{url}}"/>
          </div>
          <div class="image-info">
            <div class="image-sender">{{from}}</div>
            <div class="image-subject">{{subject}}</div>

            <div style="float:right; display:inline-block; width: 72px;">
              <div class="mm-download-tooltip mm-favorite" data-toggle="tooltip" title="Star">
                <div id="mm-sidebar-image-carousel-favorite-{{cid}}" class="inbox-icon favorite{{#if isFavorite}}On{{/if}}"></div>
              </div>
              <div class="mm-download-tooltip mm-like" data-toggle="tooltip" title="Like">
                <div id="mm-sidebar-image-carousel-like-{{cid}}" class="inbox-icon like{{#if isLiked}}On{{/if}}"></div>
              </div>
            </div>

          </div>
        </div>
      {{/each}}

    </div>

    <!-- Carousel nav -->
    {{#if moreThanOneImage}}
      <div class="carousel-control left" style="cursor:pointer;">&lsaquo;</div>
      <div class="carousel-control right" style="cursor:pointer;">&rsaquo;</div>
    {{/if}}
  </div>
  </div>
"""

class MeetMikey.View.SidebarImageCarouselModal extends MeetMikey.View.BaseModal
  template: Handlebars.compile(template)

  events:
    'hidden .modal': 'modalHidden'
    'hide .modal': 'unbindCarouselKeys'
    'click .mm-favorite': 'toggleFavoriteEvent'
    'click .mm-like': 'toggleLikeEvent'
    'click .left': 'goLeft'
    'click .right': 'goRight'

  setImageModelsCollection: (imageModelsCollection) =>
    @imageModelsCollection = imageModelsCollection

  postRender: =>
    @show()
    @$('.mmCarousel').carousel
      interval: false
    @bindCarouselKeys()

  activateModel: (model) =>
    @$('.item').removeClass 'active'
    cid = model.cid
    selector = '.item[data-cid=' + cid + ']'
    @$(selector).addClass 'active'
    foundModel = _.find @imageModelsCollection.models, (curModel) =>
      if curModel.cid == model.cid
        return true
      return false
    if foundModel
      @activeIndex = @imageModelsCollection.models.indexOf foundModel

  teardown: =>
    @unbindCarouselKeys()

  getTemplateData: =>
    moreThanOneImage = false
    if @imageModelsCollection and ( @imageModelsCollection.length > 1 )
      moreThanOneImage = true
      
    object = {}
    object.models = _.invoke(@imageModelsCollection.models, 'decorate')
    object.moreThanOneImage = moreThanOneImage
    object

  toggleFavoriteEvent: (event) =>
    event.preventDefault()
    cid = $(event.currentTarget).closest('.item').attr('data-cid')
    model = @imageModelsCollection.get cid
    elementId = '#mm-sidebar-image-carousel-favorite-' + model.cid
    MeetMikey.Helper.FavoriteAndLike.toggleFavorite model, elementId, 'sidebarImageCarousel', (status) =>
      if status == 'success'
        sidebarElementId = '#mm-sidebar-favorite-' + model.cid
        MeetMikey.Helper.FavoriteAndLike.updateModelFavoriteDisplay model, sidebarElementId

  toggleLikeEvent: (event) =>
    event.preventDefault()
    cid = $(event.currentTarget).closest('.item').attr('data-cid')
    model = @imageModelsCollection.get cid
    elementId = '#mm-sidebar-image-carousel-like-' + model.cid
    MeetMikey.Helper.FavoriteAndLike.toggleLike model, elementId, 'sidebarImageCarousel', (status) =>
      if status == 'success'
        sidebarElementId = '#mm-sidebar-like-' + model.cid
        MeetMikey.Helper.FavoriteAndLike.updateModelLikeDisplay model, sidebarElementId

  bindCarouselKeys: =>
    @unbindCarouselKeys()
    $(document).on 'keydown', @keyHandler

  unbindCarouselKeys: =>
    $(document).off 'keydown', @keyHandler

  goLeft: =>
    if @activeIndex and ( @activeIndex > 0 )
      @activeIndex--
    @activateModel @imageModelsCollection.models[ @activeIndex ]

  goRight: =>
    if ( @activeIndex == 0 or @activeIndex > 0 ) and ( @activeIndex < ( @imageModels.length - 1 ) )
      @activeIndex++
    @activateModel @imageModels[ @activeIndex ]

  isModalVisible: =>
    @$('.mmCarousel').parent().hasClass 'fade-in'

  keyHandler: (e) =>
    if e.keyCode == 37
      if @isModalVisible()
        @goLeft()
        return false
    if e.keyCode == 39
      if @isModalVisible()
        @goRight()
        return false
    if e.keyCode == 27
      if @isModalVisible()
        @hide()
        return false