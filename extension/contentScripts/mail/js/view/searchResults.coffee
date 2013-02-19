template = """
  <div id="mm-search-tabs"></div>
  <div id="mm-search-attachments-tab" style="display: none;"></div>
  <div id="mm-search-links-tab" style="display: none;"></div>
"""
class MeetMikey.View.SearchResults extends MeetMikey.View.Base
  template: Handlebars.compile(template)

  subViews:
    'tabs':
      view: MeetMikey.View.Tabs
      selector: '#mm-search-tabs'
    'attachments':
      view: MeetMikey.View.Attachments
      selector: '#mm-search-attachments-tab'
    'links':
      view: MeetMikey.View.Links
      selector: '#mm-search-links-tab'

  tabs:
    email: '.UI'
    attachments: '#mm-search-attachments-tab'
    links: '#mm-search-links-tab'

  postRender: =>
    @subView('tabs').on 'clicked:tab', @showTab

  showTab: (tab) =>
    contentSelector = _.values(@tabs).join(', ')
    $(contentSelector).hide()
    $(@tabs[tab]).show()

  teardown: =>
    @subView('tabs').off 'clicked:tab'

  setResults: (res) =>
    attachments = new MeetMikey.Collection.Attachments res.attachments
    links = new MeetMikey.Collection.Links res.links
    @subViews.attachments.view.collection = attachments
    @subViews.links.view.collection = links


