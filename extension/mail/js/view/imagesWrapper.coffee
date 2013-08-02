template = """
  <div class="mm-images-nonfavorite" style=""></div>
"""

class MeetMikey.View.ImagesWrapper extends MeetMikey.View.Base
  template: Handlebars.compile(template)

  subViews:
    'images':
      viewClass: MeetMikey.View.Images
      selector: '.mm-images-nonfavorite'
      args: {}

  postInitialize: =>
    @subView('images').collection.on 'reset add remove', () =>
      @trigger 'updateTabCount', @getCount()
    @subView('images').setFetch @options.fetch

  getCount: =>
    count = @subView('images').collection.length
    count

  initialFetch: =>
    @subView('images').initialFetch()

  restoreFromCache: () =>
    @subView('images').restoreFromCache()

  setResults: (models, query) =>
    @subView('images').setResults models, query

  getTemplateData: =>
    object = {}
    object