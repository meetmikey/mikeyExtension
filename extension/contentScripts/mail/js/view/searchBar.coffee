class MeetMikey.View.SearchBar extends MeetMikey.View.Base
  render: =>

  postInitialize: =>
    console.log @$el
    $(window).on 'hashchange', @search

  search: (e) =>
    [match, query] = (window.location.hash.match /#search\/(.+)/) ? []
    return unless match? and query?
    @trigger 'search', query

