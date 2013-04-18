class Url
  hashRegex: /#([^?]+)/
  queryRegex: /\?(.+)/

  inboxHashRegex: /^#inbox(?!\/)/
  searchHashRegex: /^#(?:search|apps)(?!.+\/)/
  appsSearchHashRegex: /^#apps/

  searchQueryHashRegex: /#(?:search|apps)\/([^\/]+)(?!.+\/)$/


  getHash: =>
    afterHash = window.location.hash
    match = afterHash.match @hashRegex

    match[0]

  setHash: (hash) =>
    url = '' + hash + @getQueryString()
    window.location.hash = url

  getQueryString: =>
    afterHash = window.location.hash
    match = afterHash.match @queryRegex

    match[0]

  getSearchQuery: =>
    afterHash = window.location.hash
    [match, query] = @getHash().match(@searchQueryHashRegex) ? []

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
