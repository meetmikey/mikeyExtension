MeetMikey.Helper.getAPIUrl = ->
  settings = MeetMikey.Settings
  settings.APIUrls[settings.env]

Handlebars.registerHelper 'getAPIUrl', MeetMikey.Helper.getAPIUrl

MeetMikey.Helper.formatDate = (timestamp) ->
  date = new Date(timestamp)
  month = date.getMonth() + 1
  day = date.getDate()
  year = date.getFullYear().toString().slice -2

  "#{month}/#{day}/#{year}"

MeetMikey.Helper.formatRecipients = (recipients) ->
  _.map(recipients, (r) -> r.name || r.email).join(', ')

MeetMikey.Helper.getFaviconURL = (url) ->
  faviconURL = ''
  if url
    faviconBaseURL = 'https://www.google.com/s2/u/0/favicons?domain='
    a = document.createElement 'a'
    a.href = url
    hostname = a.hostname
    faviconURL = faviconBaseURL + hostname
  faviconURL

MeetMikey.Helper.findSelectors = (selectors..., callback) ->
  find = ->
    targets = _.map selectors, (s) -> $ s
    if _.every(targets, (target) -> target.length > 0)
      callback targets
    else setTimeout find, 200
  find()

MeetMikey.Helper.callAPI = (options) ->
  options ?= {}
  options.url = "#{MeetMikey.Helper.getAPIUrl()}/#{options.url}"
  apiData =
    userEmail: MeetMikey.globalUser?.get('email')
    refreshToken: MeetMikey.globalUser?.get('refreshToken')

  _.extend apiData, options.data if options.data?
  options.data = apiData

  $.ajax options
