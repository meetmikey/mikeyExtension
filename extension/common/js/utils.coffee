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
