Handlebars.registerHelper 'getAPIUrl', ->
  MeetMikey.Settings.APIUrl

MeetMikey.Helper.formatDate = (timestamp) ->
  date = new Date(timestamp)
  month = date.getMonth() + 1
  day = date.getDate()
  year = date.getFullYear().toString().slice -2

  "#{month}/#{day}/#{year}"

MeetMikey.Helper.formatRecipients = (recipients) ->
  _.map(recipients, (r) -> r.name || r.email).join(', ')

MeetMikey.Helper.getReadableTypeFromMimeType = (mimeType) ->
  switch mimeType
    when 'text/plain' then readable = 'text'
    when 'application/ics' then readable = 'calendar'
    else
      readable = mimeType
      slashIndex = mimeType.indexOf '/'
      if slashIndex != -1
        readable = mimeType.substring( slashIndex + 1 )
  readable

MeetMikey.Helper.getFaviconURL = (url) ->
  faviconURL = ''
  if url
    faviconBaseURL = 'http://www.google.com/s2/u/0/favicons?domain='
    a = document.createElement 'a'
    a.href = url
    hostname = a.hostname
    faviconURL = faviconBaseURL + hostname
  faviconURL
