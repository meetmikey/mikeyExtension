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
      
  postInitialize: =>
    @subView('attachments').collection.on 'reset add remove', () =>
      @trigger 'updateTabCount', @getCount()
    if @isSearch()
      @subView('attachments').setFetch false
    else
      @subView('attachmentsFavorite').collection.on 'reset add remove', () =>
        @trigger 'updateTabCount', @getCount()

  isSearch: =>
    not @options.fetch

  getCount: =>
    count = @subView('attachments').collection.length
    if not @isSearch()
      count += @subView('attachmentsFavorite').collection.length
    count

  initialFetch: =>
    @subView('attachments').initialFetch()
    if not @isSearch()
      @subView('attachmentsFavorite').initialFetch()

  restoreFromCache: () =>
    @subView('attachments').restoreFromCache()
    if not @isSearch()
      @subView('attachmentsFavorite').restoreFromCache()

  setResults: (models, query) =>
    @subView('attachments').setResults models, query
    if not @isSearch()
      @subView('attachmentsFavorite').setResults models, query

  getTemplateData: =>
    object = {}
    object.isSearch = @isSearch()
    object