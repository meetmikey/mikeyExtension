class MeetMikey.Collection.Attachments extends MeetMikey.Collection.Base
  urlSuffix: 'attachment'
  url: MeetMikey.Helper.getAPIUrl() + '/attachment'
  model: MeetMikey.Model.Attachment

  sortKey: 'sentDate'
  sortOrder: 'desc'

  compareBy:
    sentDate: (model) -> new Date(model.get 'sentDate').getTime()
    recipients: (model) -> model.decorator.formatRecipients(model).toLowerCase()
    sender: (model) -> model.decorator.formatSender(model).toLowerCase()
