class MeetMikey.Collection.Links extends MeetMikey.Collection.Base
  url: MeetMikey.Helper.getAPIUrl() + '/link'
  model: MeetMikey.Model.Link

  sortKey: 'sentDate'
  sortOrder: 'desc'

  compareBy:
    sentDate: (model) -> new Date(model.get 'sentDate').getTime()
    recipients: (model) -> model.decorator.formatRecipients(model)
    sender: (model) -> model.decorator.formatSender(model)
    url: (model) -> model.decorator.formatUrl(model)


