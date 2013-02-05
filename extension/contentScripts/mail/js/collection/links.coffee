class MeetMikey.Collection.Links extends Backbone.Collection
  url: MeetMikey.Settings.APIUrl + '/link'
  model: MeetMikey.Model.Link
