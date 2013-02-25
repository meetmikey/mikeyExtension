imgPath = 'contentScripts/mail/img'
class AttachmentDecorator
  iconUrls:
    pdf: chrome.extension.getURL("#{imgPath}/pdf.png")
    excel: chrome.extension.getURL("#{imgPath}/excel.png")
    word: chrome.extension.getURL("#{imgPath}/word.png")
    ppt: chrome.extension.getURL("#{imgPath}/ppt.png")
    unknown: chrome.extension.getURL("#{imgPath}/unknown.png")
    image: chrome.extension.getURL("#{imgPath}/image.png")
    music: chrome.extension.getURL("#{imgPath}/music.png")
    video: chrome.extension.getURL("#{imgPath}/video.png")
    zip: chrome.extension.getURL("#{imgPath}/zip.png")

  decorate: (model) ->
    object = {}
    object.filename = model.get('filename')
    object.from = model.get('sender')?.name
    object.to = @formatRecipients model
    object.sentDate = @formatDate model
    object.size = @formatFileSize model
    object._id = model.get('_id')
    object.readableFileType = MeetMikey.Helper.getReadableTypeFromMimeType(model.get('contentType'))
    object.refreshToken =  MeetMikey.globalUser.get('refreshToken')
    object.email = encodeURIComponent MeetMikey.Helper.OAuth.getUserEmail()
    object.iconUrl = @iconUrls[@getIconUrlType(model)]

    object

  formatRecipients: (model) =>
    MeetMikey.Helper.formatRecipients model.get('recipients')

  formatDate: (model) =>
    MeetMikey.Helper.formatDate model.get('sentDate')

  getIconUrlType: (model) =>
    type = model.get 'contentType'

    if type is "application/pdf"
      "pdf"
    else if type is "application/zip"
      "zip"
    else if type is "application/vnd.oasis.opendocument.spreadsheet"
      "excel"
    else if type is "application/msword" or type is "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
      "word"
    else if type is "application/vnd.ms-powerpoint" or type is "application/vnd.openxmlformats-officedocument.presentationml.presentation"
      "ppt"
    else if model.isImage()
      "image"
    else if /audio\/.+/.test type
      "music"
    else if /video\/.+/.test type
      "video"
    else
      "unknown"

  formatFileSize: (model, precision=1) =>
    bytes = model.get('fileSize')
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
MeetMikey.Decorator.Attachment = new AttachmentDecorator()
