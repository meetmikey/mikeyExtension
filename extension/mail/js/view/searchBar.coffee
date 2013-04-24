class MeetMikey.View.SearchBar extends MeetMikey.View.Base

  render: =>

  postInitialize: =>
    $(window).on 'hashchange', @search

  teardown: =>
    $(window).off 'hashchange', @search

  search: (e) =>
    query = MeetMikey.Helper.Url.getSearchQuery()
    return unless query?
    @trigger 'search', query
