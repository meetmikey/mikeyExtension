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
    @getSearchResults query

  injectSearchResultsContainer: =>
    target = @$ '.BltHke.nH.oy8Mbf[role=main] .UI'
    target.before '<div id="mm-search-container" class="mm-container"></div>'

  injectTabBarContainer: =>
    MeetMikey.Helper.findSelectors '[id=":ro"] [gh="tm"] .nH.aqK', (targets) =>
      targets[0].append $('<div id="mm-search-tabs-container"></div>')
      @renderSubview 'tabs'

  getSearchResults: (query) =>
    MeetMikey.Helper.callAPI
      url: "search"
      type: 'GET'
      data:
        query: query
      success: (res) =>
        console.log 'search successful', res
        @subView('searchResults').setResults res
      failure: ->
        console.log 'search failed'
