class MeetMikey.Collection.Links extends MeetMikey.Collection.Base
  url: MeetMikey.Helper.getAPIUrl() + '/link'
  model: MeetMikey.Model.Link

  comparator: (model) -> -1 * new Date(model.get 'sentDate').getTime()
