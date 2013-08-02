template = """
  {{#unless isSearch}}
    <div class="mm-links-favorite" style=""></div>
  {{/unless}}
  <div class="mm-links-nonfavorite" style=""></div>
"""

class MeetMikey.View.LinksWrapper extends MeetMikey.View.Base
  template: Handlebars.compile(template)

  subViews:
    'links':
      viewClass: MeetMikey.View.Links
      selector: '.mm-links-nonfavorite'
      args: {}

  preInitialize: =>
    if not @isSearch()
      @subViews.linksFavorite = {
        viewClass: MeetMikey.View.Links
        selector: '.mm-links-favorite'
        args: {isFavorite: true}
      }

  postInitialize: =>
    @subView('links').collection.on 'reset add remove', () =>
      @trigger 'updateTabCount', @getCount()
    if not @isSearch()
      @subView('linksFavorite').collection.on 'reset add remove', () =>
        @trigger 'updateTabCount', @getCount()
    @subView('links').setFetch @options.fetch
    if not @isSearch()
      @subView('linksFavorite').setFetch @options.fetch

  isSearch: =>
    not @options.fetch

  getCount: =>
    count = @subView('links').collection.length
    if not @isSearch()
      count += @subView('linksFavorite').collection.length
    count

  initialFetch: =>
    @subView('links').initialFetch()
    if not @isSearch()
      @subView('linksFavorite').initialFetch()

  restoreFromCache: () =>
    @subView('links').restoreFromCache()
    if not @isSearch()
     @subView('linksFavorite').restoreFromCache()

  setResults: (models, query) =>
    @subView('links').setResults models, query
    if not @isSearch()
     @subView('linksFavorite').setResults models, query

  getTemplateData: =>
    object = {}
    object.isSearch = @isSearch()
    object