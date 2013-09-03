class MeetMikey.Model.Attachment extends MeetMikey.Model.Base
  idAttribute: "_id"
  decorator: MeetMikey.Decorator.Attachment

  isImage: =>
    /^image\/.+/.test @get('contentType')

  getURL: =>
    if @isImage() and MeetMikey.Helper.endsWith @get('filename'), '.tiff'
      #Apparently we have trouble converting .tiff files.  Ask Sagar.
      return @get 'image'
    email = encodeURIComponent MeetMikey.Helper.OAuth.getUserEmail()
    asymHash = MeetMikey.globalUser.get('asymHash')
    "#{MeetMikey.Helper.getAPIUrl()}/attachmentURL/#{this.id}?userEmail=#{email}&asymHash=#{asymHash}"

  putIsFavorite: (isFavorite, callback) =>
    MeetMikey.Helper.callAPI
      type: 'PUT'
      url: 'attachment/' + @get('_id')
      complete: callback
      data:
        isFavorite: isFavorite

  putIsLiked: (isLiked, callback) =>
    MeetMikey.Helper.callAPI
      type: 'PUT'
      url: 'attachment/' + @get('_id')
      complete: callback
      data:
        isLiked: isLiked

  delete: =>
    MeetMikey.Helper.callAPI
      type: 'DELETE'
      url: 'attachment/' + @get('_id')