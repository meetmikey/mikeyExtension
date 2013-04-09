class MeetMikey.View.SearchBar extends MeetMikey.View.Base
  cachedSearch : null

  render: =>

  postInitialize: =>
    $(window).on 'hashchange', @search

  search: (e) =>
    [match, query] = (window.location.hash.match /#search\/([^\/]+)(?!.+\/)$/) ? []

    return unless match? and query? and query != @cachedSearch
    @cachedSearch = query
    @trigger 'search', query