class MeetMikey.Collection.Images extends MeetMikey.Collection.Base
  url: MeetMikey.Helper.getAPIUrl() + '/image'
  model: MeetMikey.Model.Image

  sortKey: 'sentDate'
  sortOrder: 'desc'

  compareBy:
    sentDate: (model) -> new Date(model.get 'sentDate').getTime()
    recipients: (model) -> model.decorator.formatRecipients(model)
    sender: (model) -> model.decorator.formatSender(model)
