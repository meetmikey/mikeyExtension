class MeetMikey.Model.Link extends MeetMikey.Model.Resource
  idAttribute: "_id"
  decorator: MeetMikey.Decorator.Link
  apiURLRoot: 'link'

  getURL: =>
    @get 'url'