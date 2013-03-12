class MeetMikey.Collection.Attachments extends MeetMikey.Collection.Base
  url: MeetMikey.Settings.APIUrl + '/attachment'

  model: MeetMikey.Model.Attachment
  comparator: (model) -> -1 * new Date(model.get 'sentDate').getTime()
