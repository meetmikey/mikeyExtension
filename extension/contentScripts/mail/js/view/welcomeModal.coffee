imgPath = MeetMikey.Constants.imgPath
image1 = chrome.extension.getURL "#{imgPath}/welcome-1.png"
image2 = chrome.extension.getURL "#{imgPath}/welcome-2.png"
image3 = chrome.extension.getURL "#{imgPath}/welcome-3.png"
image4 = chrome.extension.getURL "#{imgPath}/welcome-4.png"
template = """
  <div id="example" class="modal hide fade modal-wide" style="display: none; ">
    <div class="modal-header">
      <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
      <h3>Mikey is ready!</h3>
    </div>
    <div class="modal-body">
      <p>Mikey has now organized some of your most recent stuff, which you can browse in the tabs or search using the Gmail search bar.</p>

      <div id="myCarousel" class="carousel slide">
        <!-- Carousel items -->
        <div class="carousel-inner">
          <div class="active item">
            <img src="#{image1}"/>
            <div class="carousel-caption">
              Simple tabs to let you filter based on the content you are looking for or want to see.
            </div>
          </div>
          <div class="item"><img src="#{image2}"/>
            <div class="carousel-caption">
              A file system made out of your attachments.
            </div>
          </div>
          <div class="item"><img src="#{image3}"/>
            <div class="carousel-caption">
              A searchable view of all your links with previews.
            </div>
          </div>
          <div class="item"><img src="#{image4}"/>
            <div class="carousel-caption">
              A searchable and browsable visual display of all your images.
            </div>
          </div>

        </div>
        <!-- Carousel nav -->
        <a class="carousel-control left" href="#myCarousel" data-slide="prev">&lsaquo;</a>
        <a class="carousel-control right" href="#myCarousel" data-slide="next">&rsaquo;</a>
      </div>


    </div>
    <div class="footer-buttons">
      <a href="#" data-dismiss="modal" class="button buttons thanks-button">Cool</a>
    </div>
  </div>
"""
class MeetMikey.View.WelcomeModal extends MeetMikey.View.Base
  template: Handlebars.compile(template)

  events:
    'click .thanks-button': 'hide'
    'click .carousel-control.left': 'prev'
    'click .carousel-control.right': 'next'

  postRender: =>
    @show()

  show: =>
    $('.modal').modal 'hide'
    @$('.modal').modal 'show'

  hide: =>
    @$('.modal').modal 'hide'

  prev: =>
    @$('.carousel').carousel 'prev'

  next: =>
    @$('.carousel').carousel 'next'
