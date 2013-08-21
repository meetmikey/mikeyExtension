template = """
  <div class="modal hide fade">
    <div class="mmCarousel carousel slide">

    <!-- Carousel items -->
    <div class="carousel-inner">
      
      {{#each models}}
        <div class="item" data-cid="{{cid}}">
          <div class="modal-image-box">
            <img class="max-image" src="{{url}}"/>
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
    'click .left': 'goLeft'
    'click .right': 'goRight'

  setImages: (decoratedImageModels) =>
    @decoratedImageModels = decoratedImageModels

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
    foundModel = _.find @decoratedImageModels, (curModel) =>
      if curModel.cid == model.cid
        return true
      return false
    if foundModel
      @activeIndex = @decoratedImageModels.indexOf foundModel

  teardown: =>
    @unbindCarouselKeys()

  getTemplateData: =>
    moreThanOneImage = false
    if @decoratedImageModels and ( @decoratedImageModels.length > 1 )
      moreThanOneImage = true
      
    object = {}
    object.models = @decoratedImageModels
    object.moreThanOneImage = moreThanOneImage
    object

  bindCarouselKeys: =>
    @unbindCarouselKeys()
    $(document).on 'keydown', @keyHandler

  unbindCarouselKeys: =>
    $(document).off 'keydown', @keyHandler

  goLeft: =>
    if @activeIndex and ( @activeIndex > 0 )
      @activeIndex--
    @activateModel @decoratedImageModels[ @activeIndex ]

  goRight: =>
    if ( @activeIndex == 0 or @activeIndex > 0 ) and ( @activeIndex < ( @decoratedImageModels.length - 1 ) )
      @activeIndex++
    @activateModel @decoratedImageModels[ @activeIndex ]

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