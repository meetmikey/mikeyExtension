class MeetMikey.Model.Link extends MeetMikey.Model.Base
  idAttribute: "_id"
  decorator: MeetMikey.Decorator.Link

  getURL: =>
    @get 'url'

  putIsFavorite: (isFavorite, callback) =>
    MeetMikey.Helper.callAPI
      type: 'PUT'
      url: 'link/' + @get('_id')
      complete: callback
      data:
        isFavorite: isFavorite

  putIsLiked: (isLiked, callback) =>
    MeetMikey.Helper.callAPI
      type: 'PUT'
      url: 'link/' + @get('_id')
      complete: callback
      data:
        isLiked: isLiked

  delete: =>
    MeetMikey.Helper.callAPI
      type: 'DELETE'
      url: 'link/' + @get('_id')