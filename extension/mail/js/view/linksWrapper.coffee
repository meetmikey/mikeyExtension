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
    @subViews.links.view.collection.on 'reset add remove', () =>
      @trigger 'updateTabCount', @subViews.links.view
    if not @isSearch()
      @subViews.linksFavorite.view.collection.on 'reset add remove', () =>
        @trigger 'updateTabCount', @subViews.linksFavorite.view
    if @options.fetch
      @subViews.links.view.options.fetch = true
      if not @isSearch()
        @subViews.linksFavorite.view.options.fetch = true

  isSearch: =>
    not @options.fetch

  getCount: =>
    count = @subViews.links.view.collection.length
    if not @isSearch()
      count += @subViews.linksFavorite.view.collection.length
    count

  initialFetch: =>
    @subViews.links.view.initialFetch()
    if not @isSearch()
      @subViews.linksFavorite.view.initialFetch()

  getTemplateData: =>
    object = {}
    object.isSearch = @isSearch()
    object