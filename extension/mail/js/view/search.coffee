class MeetMikey.View.Search extends MeetMikey.View.Base
  cachedQuery: null

  subViews:
    'searchBar':
      viewClass: MeetMikey.View.SearchBar
      selector: MeetMikey.Constants.Selectors.searchBar
      args: {owned: false}
    'tabs':
      viewClass: MeetMikey.View.Tabs
      selector: '#mm-search-tabs-container'
      args: {search: true}
    'searchResults':
      viewClass: MeetMikey.View.Inbox
      selector: '#mm-search-container'
      args: {fetch: false}

  postInitialize: =>

  enableSearch: =>
    @subView('searchBar').on 'search', @handleSearch

  handleSearch: (query) =>
    @subView('searchResults')._teardown()
    @subView('tabs')._teardown()
    @injectSearchResultsContainer()
    @injectTabBarContainer()
    @subView('tabs').on 'clicked:tab', @subView('searchResults').showTab
    @subView('searchResults').bindCountUpdate()
    @subView('searchResults').on 'updateTabCount', @subView('tabs').updateTabCount
    @renderSubview 'searchResults'
    @subView('searchResults').showTab MeetMikey.Globals.tabState
    if @cachedQuery == query
      return @subView('searchResults').restoreFromCache()
    @getSearchResults query
    @trackSearchEvent query
    @cachedQuery = query

  trackSearchEvent: (query) =>
    MeetMikey.Helper.Analytics.trackEvent 'search',
      query: query
      currentTab: MeetMikey.Globals.tabState

  injectSearchResultsContainer: =>
    selector = MeetMikey.Constants.Selectors.inboxContainer
    element =  '<div id="mm-search-container" class="mm-container" style="display: none;"></div>'
    MeetMikey.Helper.DOMManager.injectBeside selector, element

  injectTabBarContainer: =>
    selector = MeetMikey.Constants.Selectors.tabsContainer
    element = '<div id="mm-search-tabs-container" class="mm-tabs-container"></div>'
    console.log 'search: injectTabBarContainer...'
    MeetMikey.Helper.DOMManager.injectBeside selector, element, =>
      console.log 'search: injectTabBarContainer success.'
      @renderSubview 'tabs'
      @subView('tabs').setActiveTab MeetMikey.Globals.tabState
      @$('.AO').addClass 'AO-tabs'

  getSearchResults: (query) =>
    MeetMikey.Helper.callAPI
      url: "search"
      type: 'GET'
      data:
        query: query
      success: (res) =>
        @subView('searchResults').setResults res, query
        @subView('searchResults').showTab MeetMikey.Globals.tabState
      failure: ->
        @logger.info 'search failed'

  manageEmailContainerDisplay : =>
    @logger.info 'manageEmailContainerDisplay', MeetMikey.Globals.tabState
    return if MeetMikey.Globals.tabState is 'email'
    tabsToHide = MeetMikey.Constants.Selectors.allInboxes
    $(tabsToHide).hide()
