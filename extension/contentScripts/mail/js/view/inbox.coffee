template = """
    <div id="mm-tabs"></div>
    <div class="mm-attachments-tab" style="display: none;"></div>
    <div class="mm-links-tab" style="display: none;"></div>
    <div class="mm-images-tab transitions-disabled" style="display: none;"></div>
    <div style="clear: both;"></div>
"""

class MeetMikey.View.Inbox extends MeetMikey.View.Base
  template: Handlebars.compile(template)

  subViews:
    'attachments':
      viewClass: MeetMikey.View.Attachments
      selector: '.mm-attachments-tab'
      args: {}
    'links':
      viewClass: MeetMikey.View.Links
      selector: '.mm-links-tab'
      args: {}
    'images':
      viewClass: MeetMikey.View.Images
      selector: '.mm-images-tab'
      args: {}

  tabs:
    email: MeetMikey.Settings.Selectors.allInboxes
    attachments: '.mm-attachments-tab'
    links: '.mm-links-tab'
    images: '.mm-images-tab'

  getTabs: =>
    _.chain(@tabs).keys().without('email').value()

  tabState: => MeetMikey.Globals.tabState

  preInitialize: =>
    @subViews.attachments.args.fetch = @options.fetch
    @subViews.links.args.fetch = @options.fetch
    @subViews.attachments.args.name = @options.name
    @subViews.images.args.fetch = @options.fetch

  postInitialize: =>
    @bindCountUpdate() unless @options.fetch

  postRender: =>

  showTab: (tab) =>
    @hideAllTabs()
    @manageInboxDisplay(tab)
    @managePaginationDisplay(tab)
    $(@tabs[tab]).show()
    @trackTabEvent(tab) if MeetMikey.Globals.tabState isnt tab
    MeetMikey.Globals.tabState = tab
    Backbone.trigger 'change:tab', tab
    @subView(tab)?.trigger 'showTab'

  hideAllTabs: () =>
    contentSelector = _.values(@tabs).join(', ')
    $(contentSelector).hide()

  manageInboxDisplay: (tab) =>
    method = if tab is 'email' then 'hide' else 'show'
    @$el[method]()

  managePaginationDisplay: (tab) =>
    method = if tab isnt 'email' then 'hide' else 'show'
    $(MeetMikey.Settings.Selectors.gmailPagination)[method]()

  trackTabEvent: (tab) =>
    MeetMikey.Helper.Mixpanel.trackEvent 'tabChange',
      search: !@options.fetch, tab: tab

  bindPageHandlers: =>
    Backbone.on 'clicked:next-page', @nextPage
    Backbone.on 'clicked:prev-page', @prevPage

  paginationForTab: =>
    @subView(@tabState())?.pagination

  nextPage: =>
    view = @subView @tabState()
    view.pagination.nextPage()

  prevPage: =>
    view = @subView @tabState()
    view.pagination.prevPage()

  bindCountUpdate: =>
    _.each @getTabs(), @bindCountUpdateForTab

  bindCountUpdateForTab: (tab) =>
    @subView(tab).on 'reset', @updateCountForTab(tab)
    @subView(tab).collection.on 'reset add remove', @updateCountForTab(tab)

  unbindCountUpdate: =>
    _.each @getTabs(), @unbindCountUpdateForTab

  unbindCountUpdateForTab: (tab) =>
    @subView(tab).off 'reset', @updateCountForTab(tab)
    @subView(tab).collection.off 'reset add remove', @updateCountForTab(tab)

  updateCountForTab: (tab) => (collection, orCollection) =>
    @trigger 'updateTabCount', tab, (collection.length ? orCollection.length)

  updateTabCounts: =>
    _.each @getTabs(), (tab) =>
      @updateCountForTab(tab) @subView(tab).collection.length

  setResults: (res, query) =>
    console.log 'setting results'
    @subView('attachments').setResults res.attachments, query
    @subView('links').setResults res.links, query
    @subView('images').setResults res.images, query

  teardown: =>
    @unbindCountUpdate()
