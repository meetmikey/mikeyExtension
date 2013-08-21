MeetMikey.Helper.getAPIUrl = ->
  settings = MeetMikey.Constants
  settings.APIUrls[settings.env]

Handlebars.registerHelper 'getAPIUrl', MeetMikey.Helper.getAPIUrl

MeetMikey.Helper.getStripeKey = ->
  if MeetMikey.Constants.env == 'production'
    MeetMikey.Constants.stripeKeyLive
  else
    MeetMikey.Constants.stripeKeyTest

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
    extensionVersion: MeetMikey.Constants.extensionVersion

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
  if ! resource
    {}
  else
    hoursSinceSent = MeetMikey.Helper.hoursSince resource.get('sentDate')
    if resource.collection
      listPosition = resource.collection.indexOf(resource)
    resourceId = resource.id

    props = {hoursSinceSent, listPosition, resourceId}
    _.extend props, {fileType: resource.get('docType')} if resource instanceof MeetMikey.Model.Attachment

    props

MeetMikey.Helper.trackResourceEvent = (eventType, model, opts) ->
  resourceProps = MeetMikey.Helper.getResourceProperties(model)
  props = _.extend resourceProps, opts

  MeetMikey.Helper.Analytics.trackEvent event, props

MeetMikey.Helper.trackResourceInteractionEvent = (event, resourceType, isOnInput, sourceInput) ->
  source = 'sidebar'
  if sourceInput
    source = sourceInput
  isOn = false
  if isOnInput
    isOn = true
  if event == 'resourceLike'
    isOn = true
  MeetMikey.Helper.Analytics.trackEvent event, {resourceType: resourceType, isOn: isOn, source: source}

MeetMikey.Helper.getHash = (input) ->
  hash = 0
  if ( ! input ) || ( input.length == 0 )
    return hash
  for i in [0..input.length - 1] by 1
    char = input.charCodeAt i
    hash = ((hash<<5)-hash)+char
    hash = hash & hash
  hash

MeetMikey.Helper.isRealUser = (userId=MeetMikey.globalUser?.id) ->
  return true unless userId?
  not _.contains(MeetMikey.Constants.MikeyTeamUserIds, userId)

MeetMikey.Helper.encodeB64 = (obj) ->
  # btoa dies on utf-8 strings, escape/unescape fixes
  str = JSON.stringify obj
  window.btoa unescape encodeURIComponent str

MeetMikey.Helper.clearCheckTabsInterval = ->
  if MeetMikey.Globals.checkTabsInterval
    clearInterval MeetMikey.Globals.checkTabsInterval
    MeetMikey.Globals.checkTabsInterval = null

String.prototype.capitalize = () ->
  this.charAt(0).toUpperCase() + this.slice(1)

MeetMikey.Helper.isString  = ( input ) ->
  if typeof input == 'string'
    return true
  false





#CONVERSION FUNCTIONS...
###############################



#Always returns a string value
MeetMikey.Helper.decimalToHex = ( decimalInput ) ->
  decimalString = decimalInput
  if not MeetMikey.Helper.isString( decimalString )
    decimalString = decimalInput.toString()
  hex = MeetMikey.Helper.convertBase decimalString, 10, 16
  hex

#Always returns a string value
MeetMikey.Helper.hexToDecimal = ( hexInput ) ->
  hexString = hexInput
  if not MeetMikey.Helper.isString( hexString )
    hexString = hexInput.toString()
  if (hexString.substring(0, 2) == '0x')
    hexString = hexString.substring(2)
  hexString = hexString.toLowerCase()
  MeetMikey.Helper.convertBase hexString, 16, 10

# Adds two arrays for the given base (10 or 16), returning the result.
# This turns out to be the only "primitive" operation we need.
MeetMikey.Helper.convertAdd = ( x, y, base ) ->
  z = []
  n = Math.max x.length, y.length
  carry = 0
  i = 0
  while (i < n ) or carry
    xi = 0
    if i < x.length
      xi = x[i]

    yi = 0
    if i < y.length
      yi = y[i]

    zi = carry + xi + yi
    z.push(zi % base)
    carry = Math.floor(zi / base)
    i++
  z

# Returns a*x, where x is an array of decimal digits and a is an ordinary
# JavaScript number. base is the number base of the array x.
MeetMikey.Helper.convertMultiplyByNumber = ( num, x, base ) ->
  if num < 0
    return null
  if num == 0
    return []

  result = []
  power = x
  while 1
    if num & 1
      result = MeetMikey.Helper.convertAdd result, power, base
    num = num >> 1
    if num == 0
      break
    power = MeetMikey.Helper.convertAdd power, power, base
  result

MeetMikey.Helper.parseToDigitsArray = ( str, base ) ->
  digits = str.split ''
  ary = []
  for i in [(digits.length - 1)..0] by -1
    n = parseInt digits[i], base
    if isNaN n
      return null
    ary.push n
  ary

MeetMikey.Helper.convertBase = ( str, fromBase, toBase ) ->
  digits = MeetMikey.Helper.parseToDigitsArray str, fromBase
  if digits == null
    return null

  outArray = []
  power = [1]
  for i in [0..(digits.length - 1)] by 1
    # invariant: at this point, fromBase^i = power
    if digits[i]
      outArray = MeetMikey.Helper.convertAdd(outArray, MeetMikey.Helper.convertMultiplyByNumber(digits[i], power, toBase), toBase)
    power = MeetMikey.Helper.convertMultiplyByNumber fromBase, power, toBase

  out = ''
  for i in [(outArray.length - 1)..0] by -1
    out += outArray[i].toString toBase
  out