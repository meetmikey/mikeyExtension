class MeetMikey.Model.Attachment extends Backbone.Model
  idAttribute: "_id"

  isImage: =>
    /^image\/.+/.test @get('contentType')
