class MeetMikey.Collection.Attachments extends MeetMikey.Collection.Base
  url: MeetMikey.Helper.getAPIUrl() + '/attachment'

  model: MeetMikey.Model.Attachment
  comparator: (model) -> -1 * new Date(model.get 'sentDate').getTime()
