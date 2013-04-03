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

MeetMikey.Helper.formatSender = (sender) ->
  sender?.name || sender?.email

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
  options.cache = false
  apiData =
    userEmail: MeetMikey.globalUser?.get('email')
    asymHash: MeetMikey.globalUser?.get('asymHash')

  _.extend apiData, options.data if options.data?
  options.data = apiData

  $.ajax options

MeetMikey.Helper.hoursSince = (timestamp) ->
  time = new Date(timestamp).getTime()
  delta = Date.now() - time
  seconds = delta / 1000
  hours = seconds / 3600

  Math.floor hours


MeetMikey.Helper.getResourceProperties = (resource) ->
  hoursSinceSent = MeetMikey.Helper.hoursSince resource.get('sentDate')
  listPosition = resource.collection.indexOf(resource)
  resourceId = resource.id

  props = {hoursSinceSent, listPosition, resourceId}
  _.extend props, {fileType: resource.get('docType')} if resource instanceof MeetMikey.Model.Attachment

  props

MeetMikey.Helper.trackResourceEvent = (event, model, opts) ->
  resourceProps = MeetMikey.Helper.getResourceProperties(model)
  props = _.extend resourceProps, opts

  MeetMikey.Helper.Mixpanel.trackEvent event, props

MeetMikey.Helper.getHash = (input) ->
  hash = 0
  if ( ! input ) || ( input.length == 0 )
    return hash
  for i in [0..input.length - 1] by 1
    char = input.charCodeAt i
    hash = ((hash<<5)-hash)+char
    hash = hash & hash
  hash

MeetMikey.Helper.getBetaCodeHash = (betaCodeInput) ->
  MeetMikey.Helper.getHash betaCodeInput
