class MeetMikey.Model.Attachment extends MeetMikey.Model.Resource
  idAttribute: "_id"
  decorator: MeetMikey.Decorator.Attachment
  apiURLRoot: 'attachment'

  isImage: =>
    /^image\/.+/.test @get('contentType')

  getURL: =>
    if @isImage() and MeetMikey.Helper.endsWith @get('filename'), '.tiff'
      #Apparently we have trouble converting .tiff files.  Ask Sagar.
      return @get 'image'
    email = encodeURIComponent MeetMikey.Helper.OAuth.getUserEmail()
    asymHash = MeetMikey.globalUser.get('asymHash')
    "#{MeetMikey.Helper.getAPIUrl()}/attachmentURL/#{this.id}?userEmail=#{email}&asymHash=#{asymHash}"