class MeetMikey.Decorator.Attachment
  constructor: (@model) ->
    @filename = @model.get 'filename'
    @from = @model.get('sender')?.name
    @to = @formatRecipients()
    @sentDate = @formatDate()
    @size = @formatFileSize()

  formatRecipients: =>
    MeetMikey.Helper.formatRecipients @model.get('recipients')

  formatDate: =>
    MeetMikey.Helper.formatDate @model.get('sentDate')

  formatFileSize: (precision=1) ->
    bytes = @model.get('size')
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
      "#{convert bytes, terabyte} TB"
    else
      "#{bytes} B"

