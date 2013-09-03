template = """
  {{#unless isSearch}}
    <div class="mm-links-favorite" style=""></div>
  {{/unless}}
  <div class="mm-links-nonfavorite" style=""></div>
"""

class MeetMikey.View.LinksWrapper extends MeetMikey.View.ResourcesWrapper
  template: Handlebars.compile(template)

  subViews:
    'links':
      viewClass: MeetMikey.View.Links
      selector: '.mm-links-nonfavorite'
      args: {fetch: true}

  preInitialize: =>
    if @isSearch()
      delete @subViews.linksFavorite
    else
      @subViews.linksFavorite = {
        viewClass: MeetMikey.View.Links
        selector: '.mm-links-favorite'
        args: {isFavorite: true, fetch: true}
      }

  getFavoriteSubview: () =>
    if @isSearch()
      return null
    @subView 'linksFavorite'

  getNonFavoriteSubview: () =>
    @subView 'links'