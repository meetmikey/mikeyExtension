template = """
  {{#unless isSearch}}
    <div class="mm-attachments-favorite" style=""></div>
  {{/unless}}
  <div class="mm-attachments-nonfavorite" style=""></div>
"""

class MeetMikey.View.AttachmentsWrapper extends MeetMikey.View.ResourcesWrapper
  template: Handlebars.compile(template)

  subViews:
    'attachments':
      viewClass: MeetMikey.View.Attachments
      selector: '.mm-attachments-nonfavorite'
      args: {fetch: true}

  preInitialize: =>
    if @isSearch()
      delete @subViews.attachmentsFavorite
    else
      @subViews.attachmentsFavorite = {
        viewClass: MeetMikey.View.Attachments
        selector: '.mm-attachments-favorite'
        args: {isFavorite: true, fetch: true}
      }

  getFavoriteSubview: () =>
    if @isSearch()
      return null
    @subView 'attachmentsFavorite'

  getNonFavoriteSubview: () =>
    @subView 'attachments'