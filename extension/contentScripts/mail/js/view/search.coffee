class MeetMikey.View.Search extends MeetMikey.View.Base
  renderSelf: false
  renderChildren: false

  subViews:
    'searchBar':
      view: MeetMikey.View.SearchBar
      selector: '#gbqf'
    'searchResults':
      view: MeetMikey.View.SearchResults
      selector: '#mm-search-container'

  postRender: =>
    @subView('searchBar').on 'search', @handleSearch

  handleSearch: (query) =>
    @subView('searchResults')._teardown()
    @injectSearchResultsContainer()
    @renderSubview 'searchResults'
    @getSearchResults query

  injectSearchResultsContainer: =>
    target = @$ '.BltHke.nH.oy8Mbf[role=main] .UI'
    target.before '<div id="mm-search-container"></div>'

  getSearchResults: (query) =>
    MeetMikey.Helper.callAPI
      url: "search"
      type: 'GET'
      data:
        query: query
      success: (res) =>
        console.log 'search successful', res
        @subViews.searchResults.view.setResults res
      failure: ->
        console.log 'search failed'
