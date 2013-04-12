class MeetMikey.View.SearchBar extends MeetMikey.View.Base

  render: =>

  postInitialize: =>
    $(window).on 'hashchange', @search

  teardown: =>
    $(window).off 'hashchange', @search

  search: (e) =>
    [match, query] = (window.location.hash.match /#(?:search|apps)\/([^\/]+)(?!.+\/)$/) ? []
    return unless match? and query?
    console.log 'trigger search', query
    console.log 'cid', @cid
    @trigger 'search', query
