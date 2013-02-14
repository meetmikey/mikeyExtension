Handlebars.registerHelper 'getAPIUrl', ->
  MeetMikey.Settings.APIUrl

Handlebars.registerHelper 'formatDate', (timestamp) ->
  date = new Date(timestamp)
  month = date.getMonth() + 1
  day = date.getDate()
  year = date.getFullYear().toString().slice -2

  "#{month}/#{day}/#{year}"


Handlebars.registerHelper 'formatBytes', (bytes, precision=1) ->
  convert = (n, unit) ->
    (n / unit).toFixed(precision)

  kilobyte = 1024
  megabyte = kilobyte * 1024
  gigabyte = megabyte * 1024
  terabyte = gigabyte * 1024

  if 0 <= bytes < kilobyte
    "#{bytes} B"
  else if kilobyte <= bytes < megabyte
    "#{convert bytes, kilobyte} KB"
  else if megabyte <= bytes < gigabyte
    "#{convert bytes, megabyte} MB"
  else if gigabyte <= bytes < terabyte
    "#{convert bytes, gigabyte} GB"
  else if terabyte <= bytes
    "#{convert bytes, gigabyte} TB"
  else
    "#{bytes} B"

Handlebars.registerHelper 'formatRecipients', (recipients) ->
  _.map(recipients, (r) -> r.name || r.email).join(', ')

