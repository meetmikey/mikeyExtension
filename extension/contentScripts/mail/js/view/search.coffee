class MeetMikey.View.Search extends MeetMikey.View.Base
  subViews:
    'searchBar':
      viewClass: MeetMikey.View.SearchBar
      selector: '#gbqf'
    'tabs':
      viewClass: MeetMikey.View.Tabs
      selector: '#mm-search-tabs-container'
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
    @getSearchResults query

  injectSearchResultsContainer: =>
    selector = '.BltHke.nH.oy8Mbf[role=main] .UI'
    element =  '<div id="mm-search-container" class="mm-container" style="display: none;"></div>'
    MeetMikey.Helper.DOMManager.injectBeside selector, element

  injectTabBarContainer: =>
    element = '<div id="mm-search-tabs-container"></div>'
    MeetMikey.Helper.DOMManager.injectInto '[id=":ro"] [gh="tm"] .nH.aqK', element, =>
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
