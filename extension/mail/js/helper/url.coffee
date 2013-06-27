class Url
  hashRegex: /#([^?]*)/
  queryRegex: /\?(.+)/

  inboxHashRegex: /^(?:$|#inbox(?!\/))/
  searchHashRegex: /^#(?:search|apps)(?!.+\/)/
  appsSearchHashRegex: /^#apps/

  searchQueryHashRegex: /#(?:search|apps|advanced-search)\/([^\/]+)(?!.+\/)$/


  getHash: =>
    afterHash = window.location.hash
    return '' if afterHash is ''
    match = afterHash.match @hashRegex

    match?[0]

  setHash: (hash) =>
    query = @getQueryString()
    url = if query? then '' + hash + query else hash
    window.location.hash = url

  getQueryString: =>
    afterHash = window.location.hash
    match = afterHash.match @queryRegex

    match?[0]

  getSearchQuery: =>
    afterHash = window.location.hash
    [match, query] = @getHash().match(@searchQueryHashRegex) ? []

    if query?.substring('advanced-search')
      query = MeetMikey.Helper.getSearchQueryFromBox()

    query

  inInbox: =>
    @inboxHashRegex.test @getHash()

  inSearch: =>
    @searchHashRegex.test @getHash()

  inAppsSearch: =>
    @appsSearchHashRegex.test @getHash()

  inViewWithTabs: =>
    @inInbox() or @inSearch()

MeetMikey.Helper.Url = new Url()
