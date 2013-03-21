class MeetMikey.Collection.Images extends MeetMikey.Collection.Base
  url: MeetMikey.Helper.getAPIUrl() + '/image'
  model: MeetMikey.Model.Image

  comparator: (model) -> -1 * new Date(model.get 'sentDate').getTime()
