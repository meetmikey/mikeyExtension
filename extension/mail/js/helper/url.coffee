class Url
  hashRegex: /#([^?]*)/
  queryRegex: /\?(.+)/

  inboxHashRegex: /^(?:$|#inbox(?!\/))/
  searchHashRegex: /^#(?:search|apps)(?!.+\/)/
  appsSearchHashRegex: /^#apps/
  threadHashRegex: /#(search\/){0,1}((?!search|\s|\/).)+\/[a-f0-9]{16}/

  searchQueryHashRegex: /#(?:search|apps)\/([^\/]+)(?!.+\/)$/


  getHash: =>
    afterHash = window.location.hash
    return '' if afterHash is ''
    match = afterHash.match @hashRegex

    match?[0]

  getThreadHex: =>
    threadHex = ''
    if @inThread()
      hash = @getHash()
      lastSlashIndex = hash.lastIndexOf '/'
      if lastSlashIndex != -1
        threadHex = hash.substring ( lastSlashIndex + 1 )
    threadHex

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

    query

  inInbox: =>
    @inboxHashRegex.test @getHash()

  inSearch: =>
    @searchHashRegex.test @getHash()

  inAppsSearch: =>
    @appsSearchHashRegex.test @getHash()

  inThread: =>
    @threadHashRegex.test @getHash()

  inViewWithTabs: =>
    @inInbox() or @inSearch()

MeetMikey.Helper.Url = new Url()
