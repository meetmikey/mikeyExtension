template = """
    <div id="mm-tabs"></div>
    <div class="mm-attachments-tab" style="display: none;"></div>
    <div class="mm-links-tab" style="display: none;"></div>
    <div class="mm-images-tab" style="display: none;"><div class="mm-images-tab-inner transitions-disabled"></div></div>
    <div style="clear: both;"></div>
"""

class MeetMikey.View.Inbox extends MeetMikey.View.Base
  template: Handlebars.compile(template)

  safeFind: MeetMikey.Helper.DOMManager.find

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
      selector: '.mm-images-tab-inner'
      args: {}

  tabs:
    email: MeetMikey.Constants.Selectors.allInboxes
    attachments: '.mm-attachments-tab'
    links: '.mm-links-tab'
    images: '.mm-images-tab'

  getTabs: =>
    _.chain(@tabs).keys().without('email').value()

  adjustHeight: =>
    bodyHeight = parseInt( @safeFind('body').css('height'), 10 )
    offset = 191
    if MeetMikey.Globals.layout == 'compact'
      offset = 138
    height = bodyHeight - offset
    height = height + 'px'
    MeetMikey.Helper.DOMManager.waitAndFindAll ['.mm-attachments-tab', '.mm-links-tab', '.mm-images-tab'], =>
      if MeetMikey.Globals.previewPane
        @$('.mm-attachments-tab').css 'height', height
        @$('.mm-links-tab').css 'height', height
        @$('.mm-images-tab').css 'height', height

  tabState: => MeetMikey.Globals.tabState

  preInitialize: =>
    @tabs = $.extend true, {}, @tabs # deep copy tabs
    if @options.fetch and MeetMikey.Globals.multipleInbox
      @tabs.email = MeetMikey.Constants.Selectors.multipleInboxContainer + ', ' + @tabs.email
    @subViews.attachments.args.fetch = @options.fetch
    @subViews.links.args.fetch = @options.fetch
    @subViews.images.args.fetch = @options.fetch

  postInitialize: =>
    @bindCountUpdate() unless @options.fetch

  postRender: =>
    @adjustHeight()
    @bindWindowResize()

  bindWindowResize: =>
    $(window).on 'resize', @adjustHeight

  teardown: =>
    @resetEmailDisplay()
    @unbindCountUpdate()

  initialFetch: =>
    return unless @options.fetch
    @subView('attachments').initialFetch()
    @subView('links').initialFetch()
    @subView('images').initialFetch()

  restoreFromCache: =>
    @subView('attachments').restoreFromCache()
    @subView('links').restoreFromCache()
    @subView('images').restoreFromCache()

  showTab: (tab) =>
    @hideAllTabs()
    @manageInboxDisplay(tab)
    @managePaginationDisplay(tab)
    @manageAppsSearchDisplay(tab) if @inAppsSearch()
    $(@tabs[tab]).show()
    $(MeetMikey.Constants.Selectors.scrollContainer).scrollTop 0
    MeetMikey.Globals.tabState = tab
    Backbone.trigger 'change:tab', tab
    @subView(tab)?.trigger 'showTab'

  hideAllTabs: () =>
    contentSelector = _.values(@tabs).join(', ')
    @safeFind(contentSelector).hide()

  manageInboxDisplay: (tab) =>
    method = if tab is 'email' then 'hide' else 'show'
    @$el[method]()

  managePaginationDisplay: (tab) =>
    method = if tab isnt 'email' then 'hide' else 'show'
    $(MeetMikey.Constants.Selectors.gmailPagination)[method]()

  manageAppsSearchDisplay: (tab) =>
    method = if tab isnt 'email' then 'hide' else 'show'
    delay = if method is 'hide' then 400 else 0
    $(MeetMikey.Constants.Selectors.appsSearchControl)[method]()
    tableSelector = MeetMikey.Constants.Selectors.appsSearchTable
    _.delay (=> @$el.parent().find(tableSelector)[method]()), delay
    onlySearchDocsSelector = MeetMikey.Constants.Selectors.appsSearchOnlyDocs
    _.delay (=> @$el.parent().find(onlySearchDocsSelector)[method]()), delay

  resetEmailDisplay: =>
    $(MeetMikey.Constants.Selectors.allInboxes).show()
    $(MeetMikey.Constants.Selectors.multipleInboxContainer).show()

  inAppsSearch: MeetMikey.Helper.Url.inAppsSearch

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

  # not needed anymore ?
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
    @logger.info 'setting results'
    @subView('attachments').setResults res.attachments, query
    @subView('links').setResults res.links, query
    @subView('images').setResults res.images, query
