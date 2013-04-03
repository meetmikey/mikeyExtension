class MeetMikey.Model.Attachment extends MeetMikey.Model.Base
  idAttribute: "_id"

  decorator: MeetMikey.Decorator.Attachment

  isImage: =>
    /^image\/.+/.test @get('contentType')

  getUrl: =>
    email = encodeURIComponent MeetMikey.Helper.OAuth.getUserEmail()
    asymHash = MeetMikey.globalUser.get('asymHash')
    "#{MeetMikey.Helper.getAPIUrl()}/attachmentURL/#{this.id}?userEmail=#{email}&asymHash=#{asymHash}"
