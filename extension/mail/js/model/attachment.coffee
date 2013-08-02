class MeetMikey.Model.Attachment extends MeetMikey.Model.Base
  idAttribute: "_id"
  decorator: MeetMikey.Decorator.Attachment

  isImage: =>
    /^image\/.+/.test @get('contentType')

  getUrl: =>
    email = encodeURIComponent MeetMikey.Helper.OAuth.getUserEmail()
    asymHash = MeetMikey.globalUser.get('asymHash')
    "#{MeetMikey.Helper.getAPIUrl()}/attachmentURL/#{this.id}?userEmail=#{email}&asymHash=#{asymHash}"

  putIsFavorite: (isFavorite, callback) =>
    apiData =
      userEmail: MeetMikey.globalUser.get('email')
      asymHash: MeetMikey.globalUser.get('asymHash')
      extensionVersion: MeetMikey.Constants.extensionVersion
      isFavorite: isFavorite

    $.ajax
      type: 'PUT'
      url: MeetMikey.Helper.getAPIUrl() + '/attachment/' + @get('_id')
      data: apiData
      complete: callback

  putIsLiked: (isLiked, callback) =>
    apiData =
      userEmail: MeetMikey.globalUser.get('email')
      asymHash: MeetMikey.globalUser.get('asymHash')
      extensionVersion: MeetMikey.Constants.extensionVersion
      isLiked: isLiked

    $.ajax
      type: 'PUT'
      url: MeetMikey.Helper.getAPIUrl() + '/attachment/' + @get('_id')
      data: apiData
      complete: callback

  delete: =>

    apiData =
      userEmail: MeetMikey.globalUser.get('email')
      asymHash: MeetMikey.globalUser.get('asymHash')
      extensionVersion: MeetMikey.Constants.extensionVersion

    $.ajax
      type: 'DELETE'
      url: MeetMikey.Helper.getAPIUrl() + '/attachment/' + @get('_id')
      data: apiData
      error: (data) ->
        console.log 'hide error', data
      #success: (data) ->
        #console.log 'hide success', data