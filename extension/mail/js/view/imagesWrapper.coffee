template = """
  <div class="mm-images-nonfavorite" style=""></div>
"""

class MeetMikey.View.ImagesWrapper extends MeetMikey.View.ResourcesWrapper
  template: Handlebars.compile(template)

  subViews:
    'images':
      viewClass: MeetMikey.View.Images
      selector: '.mm-images-nonfavorite'
      args: {}

  getFavoriteSubview: () =>
    null

  getNonFavoriteSubview: () =>
    @subView 'images'