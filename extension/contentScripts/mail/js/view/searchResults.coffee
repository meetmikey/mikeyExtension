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

  getTabs: =>
    _(@tabs).keys().without('email').value()

  postRender: =>
    @subView('tabs').on 'clicked:tab', @showTab

  bindCountUpdate: =>
    _.each @getTabs(), (tab) => @bindCountUpdateForTab tab

  bindCountUpdateForTab: (tab) =>
    @subView(tab).collection.on 'reset add remove', @updateCountForTab(tab)

  updateCountForTab: (tab) => (collection) =>
    @subView('tabs').changeTabCount tab, collection.length

  showTab: (tab) =>
    contentSelector = _.values(@tabs).join(', ')
    $(contentSelector).hide()
    $(@tabs[tab]).show()

  teardown: =>
    @subView('tabs').off 'clicked:tab'

  setResults: (res) =>
    console.log 'setting results'
    attachments = new MeetMikey.Collection.Attachments res.attachments
    links = new MeetMikey.Collection.Links res.links
    @subView('attachments').collection = attachments
    @subView('links').collection = links
    @renderSubview('attachments')
    @renderSubview('links')
    @updateCountForTab('attachments')(attachments)
    @updateCountForTab('links')(links)
