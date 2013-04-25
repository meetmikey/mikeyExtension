class MeetMikey.Collection.Attachments extends MeetMikey.Collection.Base
  url: MeetMikey.Helper.getAPIUrl() + '/attachment'
  model: MeetMikey.Model.Attachment

  sortKey: 'sentDate'
  sortOrder: 'desc'

  compareBy:
    sentDate: (model) -> new Date(model.get 'sentDate').getTime()
    recipients: (model) -> model.decorator.formatRecipients(model)
    sender: (model) -> model.decorator.formatSender(model)
