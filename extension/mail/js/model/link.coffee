class MeetMikey.Model.Link extends MeetMikey.Model.Base
  idAttribute: "_id"
  decorator: MeetMikey.Decorator.Link

  putIsFavorite: (isFavorite, callback) =>
    apiData =
      userEmail: MeetMikey.globalUser.get('email')
      asymHash: MeetMikey.globalUser.get('asymHash')
      extensionVersion: MeetMikey.Constants.extensionVersion
      isFavorite: isFavorite

    $.ajax
      type: 'PUT'
      url: MeetMikey.Helper.getAPIUrl() + '/link/' + @get('_id')
      data: apiData
      complete: callback

  delete: =>
    apiData =
      userEmail: MeetMikey.globalUser.get('email')
      asymHash: MeetMikey.globalUser.get('asymHash')
      extensionVersion: MeetMikey.Constants.extensionVersion

    $.ajax
      type: 'DELETE'
      url: MeetMikey.Helper.getAPIUrl() + '/link/' + @get('_id')
      data: apiData
      error: (data) ->
        console.log 'hide error', data
      #success: (data) ->
        #console.log 'hide success', data