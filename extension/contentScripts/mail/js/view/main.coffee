class MeetMikey.View.Main extends MeetMikey.View.Base
  contentSelector: MeetMikey.Settings.Selectors.contentContainer
  subViews:
    'tabs':
      viewClass: MeetMikey.View.Tabs
      selector: '#mm-tabs-container'
      args: {search: false}
    'inbox':
      viewClass: MeetMikey.View.Inbox
      selector: '#mm-container'
      args: {fetch: true, name: 'main'}
    'search':
      viewClass: MeetMikey.View.Search
      selector: MeetMikey.Settings.Selectors.topLevelSelector
      args: {name: 'search', render: false, renderChildren: false}
    'sidebar':
      viewClass: MeetMikey.View.Sidebar
      selector: '.nM[role=navigation]'
      args: {render: false}

  preInitialize: =>
    @injectInboxContainer()
    @injectTabBarContainer()
    MeetMikey.Helper.Theme.setup()
    @options.render = false

  postInitialize: =>
    @subView('sidebar').on 'clicked:inbox', @showEmailTab
    @subView('tabs').on 'clicked:tab', @subView('inbox').showTab
    @subView('inbox').on 'updateTabCount', @subView('tabs').updateTabCount
    Backbone.on 'change:tab', (tab) =>
      @setPaginationState @subView('inbox').paginationForTab(tab)
    $(window).on 'hashchange', @pageNavigated
    MeetMikey.Globals.tabState = 'email'

  preRender: =>

  postRender: =>

  teardown: =>
    Backbone.off 'change:tab'

  detectTheme: =>
    color = $(MeetMikey.Settings.Selectors.sidebarText).css 'color'
    inboxColor = $(MeetMikey.Settings.Selectors.inboxReadText)


  detectLayout: =>
    $elem = $(MeetMikey.Settings.Selectors.tableCell)
    padding = parseFloat $elem.css('padding-top')

    if padding < 4.5
      'compact'
    else if 8.5 <= padding
      'comfortable'
    else
      'cozy'

  setLayout: (layout='compact') =>
    @$el.addClass layout

  setPaginationState: (pagination) =>
    @subView('tabs').subView('pagination').setState pagination

  injectInboxContainer: =>
    element = '<div id="mm-container" class="mm-container" style="display: none;"></div>'
    MeetMikey.Helper.DOMManager.injectBeside @options.inboxTarget, element

  injectTabBarContainer: =>
    selector = MeetMikey.Settings.Selectors.tabsContainer
    element = '<div id="mm-tabs-container" class="mm-tabs-container"></div>'
    MeetMikey.Helper.DOMManager.injectInto selector, element, =>
      @$(@contentSelector).addClass 'AO-tabs'

  showEmailTab: =>
    @subView('tabs').setActiveTab 'email'
    @subView('inbox').showTab 'email'

  pageNavigated: =>
    viewWithTabs = /#search(?!.+\/)|#inbox(?!\/)/.test window.location.hash
    if viewWithTabs
      @$(@contentSelector).addClass 'AO-tabs'
    else
      @$(@contentSelector).removeClass 'AO-tabs'
