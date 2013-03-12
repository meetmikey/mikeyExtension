class MeetMikey.Collection.Links extends MeetMikey.Collection.Base
  url: MeetMikey.Settings.APIUrl + '/link'
  model: MeetMikey.Model.Link

  comparator: (model) -> -1 * new Date(model.get 'sentDate').getTime()
