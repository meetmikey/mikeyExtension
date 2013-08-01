template = """
  {{#unless isSearch}}
    <div class="mm-attachments-favorite" style=""></div>
  {{/unless}}
  <div class="mm-attachments-nonfavorite" style=""></div>
"""

class MeetMikey.View.AttachmentsWrapper extends MeetMikey.View.Base
  template: Handlebars.compile(template)

  subViews:
    'attachments':
      viewClass: MeetMikey.View.Attachments
      selector: '.mm-attachments-nonfavorite'
      args: {}

  preInitialize: =>
    if not @isSearch()
      @subViews.attachmentsFavorite = {
        viewClass: MeetMikey.View.Attachments
        selector: '.mm-attachments-favorite'
        args: {isFavorite: true}
      }

  postInitialize: =>
    @subViews.attachments.view.collection.on 'reset add remove', () =>
      @trigger 'updateTabCount', @subViews.attachments.view
    if not @isSearch()
      @subViews.attachmentsFavorite.view.collection.on 'reset add remove', () =>
        @trigger 'updateTabCount', @subViews.attachmentsFavorite.view
    if @options.fetch
      @subViews.attachments.view.options.fetch = true
      if not @isSearch()
        @subViews.attachmentsFavorite.view.options.fetch = true

  isSearch: =>
    not @options.fetch

  getCount: =>
    count = @subViews.attachments.view.collection.length
    if not @isSearch()
      count += @subViews.attachmentsFavorite.view.collection.length
    count

  initialFetch: =>
    @subViews.attachments.view.initialFetch()
    if not @isSearch()
      @subViews.attachmentsFavorite.view.initialFetch()

  getTemplateData: =>
    object = {}
    object.isSearch = @isSearch()
    object