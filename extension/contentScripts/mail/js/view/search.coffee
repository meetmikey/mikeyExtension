class MeetMikey.View.Search extends MeetMikey.View.Base
  cachedQuery: null

  subViews:
    'searchBar':
      viewClass: MeetMikey.View.SearchBar
      selector: MeetMikey.Settings.Selectors.searchBar
    'tabs':
      viewClass: MeetMikey.View.Tabs
      selector: '#mm-search-tabs-container'
      args: {search: true}
    'searchResults':
      viewClass: MeetMikey.View.Inbox
      selector: '#mm-search-container'
      args: {fetch: false, name: 'searchResult'}

  postInitialize: =>
    @subView('searchBar').on 'search', @handleSearch

  handleSearch: (query) =>
    @subView('searchResults')._teardown()
    @subView('tabs')._teardown()
    @injectSearchResultsContainer()
    @injectTabBarContainer()
    @subView('tabs').on 'clicked:tab', @subView('searchResults').showTab
    @subView('searchResults').on 'updateTabCount', @subView('tabs').updateTabCount
    @renderSubview 'searchResults'
    @subView('searchResults').showTab MeetMikey.Globals.tabState
    return @subView('searchResults').restoreFromCache() if @cachedQuery == query
    @getSearchResults query
    @trackSearchEvent query
    @cachedQuery = query

  trackSearchEvent: (query) =>
    MeetMikey.Helper.Mixpanel.trackEvent 'search',
      query: query
      currentTab: MeetMikey.Globals.tabState

  injectSearchResultsContainer: =>
    selector = MeetMikey.Settings.Selectors.inboxContainer
    element =  '<div id="mm-search-container" class="mm-container" style="display: none;"></div>'
    MeetMikey.Helper.DOMManager.injectBeside selector, element

  injectTabBarContainer: =>
    selector = MeetMikey.Settings.Selectors.tabsContainer
    element = '<div id="mm-search-tabs-container" class="mm-tabs-container"></div>'
    MeetMikey.Helper.DOMManager.injectInto selector, element, =>
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
        console.log 'search successful', res
        @subView('searchResults').setResults res, query
      failure: ->
        console.log 'search failed'
