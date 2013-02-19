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
    @subViews.searchBar.view.on 'search', @handleSearch


  handleSearch: (query) =>
    @getSearchResults query
    @injectSearchResultsContainer()

  injectSearchResultsContainer: =>
    target = @$ '.BltHke.nH.oy8Mbf[role=main] .UI'
    target.before '<div id="mm-search-container"></div>'

  getSearchResults: (query) =>
    $.ajax
      url: "#{ MeetMikey.Settings.APIUrl }/search"
      type: 'GET'
      data:
        query: query
        userEmail: MeetMikey.Helper.OAuth.getUserEmail()
      success: (res) =>
        console.log 'search successful', res
        @renderSearchResults res
      failure: ->
        console.log 'search failed'

  renderSearchResults: (res) =>
    @subViews.searchResults.view.setResults res
    @renderSubview 'searchResults'

