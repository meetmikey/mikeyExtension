class MeetMikey.Collection.Attachments extends Backbone.Collection
  url: MeetMikey.Settings.APIUrl + '/attachment'

  model: MeetMikey.Model.Attachment
