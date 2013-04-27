template = """
  <div class="modal hide fade modal-wide">
    <div class="modal-header">
      <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
    </div>
    <div style="text-align: center; height: 100%; overflow: hidden; margin: 20px;" class="modal-body">
      <a href="#" class="prev-button" style="display: inline-block;">Prev</a>

      <div class="image-container" style="margin:auto;">
        <img class="image-preview"></img>
      </div>

      <a href="#" class="next-button" style="display: inline-block; float: right;">Next</a>

      <div class="image-cache" style="display: none;">
        <img class="prev-image"></img>
        <img class="next-image"></img>
      </div>
    </div>
  </div>
"""

class MeetMikey.View.ImageModal extends MeetMikey.View.Base
  template: Handlebars.compile(template)

  events:
    'click .prev-button': 'prev'
    'click .next-button': 'next'

  getTemplateData: =>
    imgSrc: @model?.getUrl()

  postInitialize: =>
    @render()

  teardown: =>
    @hide()

  show: =>
    @$('.modal').modal 'show'

  hide: =>
    @$('.modal').modal 'hide'

  showImage: (cid) =>
    @model = @collection.get cid
    @setImage()
    @show()

  setImage: =>
    console.log @$('img')
    @$('.image-preview').attr 'src', @model.getUrl()
    @$('.prev-image').attr 'src', @prevImage()?.getUrl()
    @$('.next-image').attr 'src', @nextImage()?.getUrl()

  next: =>
    image = @nextImage()
    return unless image?

    @$('.prev-image').remove()
    @$('.image-preview').detach()
      .removeClass('image-preview')
      .addClass('prev-image')
      .prependTo('.image-cache')
    @$('.next-image').detach()
      .removeClass('next-image')
      .addClass('image-preview')
      .appendTo('.image-container')
    $('<img>')
      .addClass('next-image')
      .appendTo('.image-cache')
      .attr 'src', image.getUrl()

  prev: =>
    image = @prevImage()
    return unless image?

    @$('.next-image').remove()
    @$('.image-preview').detach()
      .removeClass('image-preview')
      .addClass('next-image')
      .appendTo('.image-cache')
    @$('.prev-image').detach()
      .removeClass('prev-image')
      .addClass('image-preview')
      .appendTo('.image-container')
    $('<img>')
      .addClass('prev-image')
      .appendTo('.image-cache')
      .attr 'src', image.getUrl()

  nextImage: =>
    index = @collection.indexOf(@model)
    return if index >= @collection.length
    @model = @collection.at(index + 1)

  prevImage: =>
    index = @collection.indexOf(@model)
    return if index <= 0
    @model = @collection.at index - 1

