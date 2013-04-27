class MeetMikey.View.Main extends MeetMikey.View.Base
  contentSelector: MeetMikey.Constants.Selectors.contentContainer
  showWelcomeModal: false
  subViews:
    'tabs':
      viewClass: MeetMikey.View.Tabs
      selector: '#mm-tabs-container'
      args: {search: false}
    'inbox':
      viewClass: MeetMikey.View.Inbox
      selector: '#mm-container'
      args: {fetch: true}
    'search':
      viewClass: MeetMikey.View.Search
      selector: MeetMikey.Constants.Selectors.topLevel
      args: {render: false, renderChildren: false, owned: false}
    'sidebar':
      viewClass: MeetMikey.View.Sidebar
      selector: MeetMikey.Constants.Selectors.sideBar
      args: {render: false, owned: false}

  preInitialize: =>
    @setSelectors()
    @injectContainers()
    MeetMikey.Helper.Theme.setup()
    @options.render = false

  postInitialize: =>
    @subView('sidebar').on 'clicked:inbox', @showEmailTab
    @subView('inbox').on 'updateTabCount', @subView('tabs').updateTabCount
    Backbone.on 'change:tab', @setPaginationStateForTab
    $(window).on 'hashchange', @pageNavigated
    MeetMikey.Globals.tabState = 'email'
    @setupWhenUserOnboards()

  preRender: =>

  postRender: =>

  teardown: =>
    Backbone.off 'change:tab'
    @$(@contentSelector).removeClass 'AO-tabs'
    $(window).off 'hashchange', @pageNavigated

  setupWhenUserOnboards: =>
    if MeetMikey.globalUser.get('onboarding')
      MeetMikey.globalUser.once 'change:onboarding', @setupWhenUserOnboards
      @subView('tabs').disable()
      @showWelcomeModal = true
    else
      @injectWelcomeModal() if @showWelcomeModal
      @subView('tabs').on 'clicked:tab', @subView('inbox').showTab
      @subView('tabs').enable()
      @subView('search').enableSearch()
      @subView('inbox').initialFetch()

  setPaginationStateForTab: (tab) =>
    @setPaginationState @subView('inbox').paginationForTab(tab)

  setPaginationState: (pagination) =>
    @subView('tabs').subView('pagination').setState pagination

  setSelectors: =>
    selectors = MeetMikey.Constants.Selectors
    if MeetMikey.Globals.multipleInbox
      @inboxSelector = selectors.multipleInboxContainer
      @tabsSelector = selectors.multipleInboxTabsContainer
    else
      @inboxSelector = selectors.inboxContainer
      @tabsSelector = selectors.tabsContainer

  injectContainers: =>
    @injectInboxContainer()
    @injectTabBarContainer()

  injectInboxContainer: (selector) =>
    element = '<div id="mm-container" class="mm-container" style="display: none;"></div>'
    MeetMikey.Helper.DOMManager.injectBeside @inboxSelector, element

  injectTabBarContainer: (selector) =>
    element = '<div id="mm-tabs-container" class="mm-tabs-container"></div>'
    MeetMikey.Helper.DOMManager.injectInto @tabsSelector, element, =>
      @$(@contentSelector).addClass 'AO-tabs'

  # Rename Onboarded modal ?
  injectWelcomeModal: =>
    $('body').append $('<div id="mm-welcome-modal"></div>')
    view = new MeetMikey.View.WelcomeModal el: '#mm-welcome-modal'
    view.render()

  showEmailTab: =>
    @subView('tabs').setActiveTab 'email'
    @subView('inbox').showTab 'email'

  managePushdownDisplay: =>
    viewWithTabs = @inViewWithTabs()
    if viewWithTabs
      @$(@contentSelector).addClass 'AO-tabs'
    else
      @$(@contentSelector).removeClass 'AO-tabs'

  manageMultipleInboxDisplay: =>
    return unless MeetMikey.Globals.multipleInbox
    if @inInbox()
      @subView('tabs').$el.show()
      @subView('inbox').$el.show()
      @subView('inbox').showTab MeetMikey.Globals.tabState
    else
      @subView('tabs').$el.hide()
      @subView('inbox').$el.hide()
      @subView('inbox').resetEmailDisplay()
      @subView('search').manageEmailContainerDisplay() if @inSearch()

  pageNavigated: =>
    @managePushdownDisplay()
    @manageMultipleInboxDisplay()

  inInbox: MeetMikey.Helper.Url.inInbox

  inSearch: MeetMikey.Helper.Url.inSearch

  inViewWithTabs: MeetMikey.Helper.Url.inViewWithTabs
