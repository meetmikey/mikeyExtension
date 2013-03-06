class MeetMikey.Model.Attachment extends MeetMikey.Model.Base
  idAttribute: "_id"

  decorator: MeetMikey.Decorator.Attachment

  isImage: =>
    /^image\/.+/.test @get('contentType')
