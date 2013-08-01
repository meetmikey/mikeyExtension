template = """
  <div class="mm-images-nonfavorite" style=""></div>
"""

class MeetMikey.View.ImagesTab extends MeetMikey.View.Base
  template: Handlebars.compile(template)

  subViews:
    'images':
      viewClass: MeetMikey.View.Images
      selector: '.mm-images-nonfavorite'
      args: {}

  postInitialize: =>
    @subViews.images.view.collection.on 'reset add remove', () =>
      @trigger 'updateTabCount', @subViews.images.view
    if @options.fetch
      @subViews.images.view.options.fetch = true

  getCount: =>
    count = @subViews.images.view.collection.length
    count

  initialFetch: =>
    @subViews.images.view.initialFetch()

  getTemplateData: =>
    object = {}
    object