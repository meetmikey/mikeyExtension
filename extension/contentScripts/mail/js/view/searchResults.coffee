template = """
  <div id="mm-search-tabs"></div>
  <div id="mm-search-attachments-tab" style="display: none;"></div>
  <div id="mm-search-links-tab" style="display: none;"></div>
  <div id="mm-search-images-tab" style="display: none;"></div>
"""
class MeetMikey.View.SearchResults extends MeetMikey.View.Base
  template: Handlebars.compile(template)

  subViews:
    # 'tabs':
    #   view: MeetMikey.View.Tabs
    #   selector: '#mm-search-tabs'
    'attachments':
      viewClass: MeetMikey.View.Attachments
      selector: '#mm-search-attachments-tab'
    'links':
      viewClass: MeetMikey.View.Links
      selector: '#mm-search-links-tab'
    'images':
      viewClass: MeetMikey.View.Images
      selector: '#mm-search-images-tab'

  tabs:
    email: '.UI'
    attachments: '#mm-search-attachments-tab'
    links: '#mm-search-links-tab'
    images: '#mm-search-images-tab'

  getTabs: =>
    _.chain(@tabs).keys().without('email').value()

  postRender: =>
    # @subView('tabs').on 'clicked:tab', @showTab

  bindCountUpdate: =>
    _.each @getTabs(), (tab) => @bindCountUpdateForTab tab

  bindCountUpdateForTab: (tab) =>
    @subView(tab).collection.on 'reset add remove', @updateCountForTab(tab)

  unbindCountUpdate: =>
    _.each @getTabs(), (tab) => @unbindCountUpdateForTab tab

  unbindCountUpdateForTab: (tab) =>
    @subView(tab).collection.off 'reset add remove', @updateCountForTab(tab)

  updateCountForTab: (tab) => (collection) =>
    @subView('tabs').updateTabCount tab, collection.length

  showTab: (tab) =>
    contentSelector = _.values(@tabs).join(', ')
    $(contentSelector).hide()
    $(@tabs[tab]).show()

  teardown: =>
    # @subView('tabs').off 'clicked:tab'
    # @unbindCountUpdate()

  setResults: (res) =>
    @subView('attachments').collection.reset res.attachments
    @subView('links').collection.reset res.links
