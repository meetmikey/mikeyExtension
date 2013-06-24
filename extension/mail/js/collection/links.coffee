class MeetMikey.Collection.Links extends MeetMikey.Collection.Base
  url: MeetMikey.Helper.getAPIUrl() + '/link'
  model: MeetMikey.Model.Link

  sortKey: 'sentDate'
  sortOrder: 'desc'

  compareBy:
    sentDate: (model) -> new Date(model.get 'sentDate').getTime()
    recipients: (model) -> model.decorator.formatRecipients(model).toLowerCase()
    sender: (model) -> model.decorator.formatSender(model).toLowerCase()
    url: (model) -> model.decorator.formatUrl(model)
    title: (model) -> model.get('title') ? model.get('url')


