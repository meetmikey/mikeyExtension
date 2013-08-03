imgPath = MeetMikey.Constants.imgPath
class AttachmentDecorator
  iconUrls:
    pdf: chrome.extension.getURL("#{imgPath}/pdf.png")
    spreadsheet: chrome.extension.getURL("#{imgPath}/excel.png")
    document: chrome.extension.getURL("#{imgPath}/word.png")
    presentation: chrome.extension.getURL("#{imgPath}/ppt.png")
    other: chrome.extension.getURL("#{imgPath}/unknown.png")
    code: chrome.extension.getURL("#{imgPath}/code.png")
    image: chrome.extension.getURL("#{imgPath}/image.png")
    music: chrome.extension.getURL("#{imgPath}/music.png")
    video: chrome.extension.getURL("#{imgPath}/video.png")
    archive: chrome.extension.getURL("#{imgPath}/zip.png")

  decorate: (model) =>
    object = {}
    object.filename = model.get('filename')
    object.from = @formatSender model
    object.to = @formatRecipients model
    object.sentDate = @formatDate model
    object.size = @formatFileSize model
    object.url = model.getUrl()
    object._id = model.get('_id')
    object.cid = model.cid
    object.type = model.get 'docType'
    object.iconUrl = @iconUrls[model.get 'docType']
    object.image = model.get 'image'
    object.msgHex = model.get('gmMsgHex')
    object.subject = model.get('mailCleanSubject')
    object.deleting = model.get('deleting')
    object.isFavorite = model.get 'isFavorite'
    object.isLiked = model.get 'isLiked'

    object

  formatRecipients: (model) =>
    MeetMikey.Helper.formatRecipients model.get('recipients')

  formatSender: (model) =>
    MeetMikey.Helper.formatSender model.get('sender')

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
