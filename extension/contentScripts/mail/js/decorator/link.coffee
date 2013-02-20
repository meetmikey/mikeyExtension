class MeetMikey.Decorator.Link
  constructor: (@model) ->
    @title = @model.get('title') ? @model.get('url')
    @summary = @model.get('summary')
    @url = @model.get 'url'
    @from = @model.get('sender')?.name
    @to = @formatRecipients()
    @sentDate = @formatDate()
    @faviconURL = MeetMikey.Helper.getFaviconURL(@model.get('resolvedURL') ? @model.get('url'))

  formatRecipients: =>
    MeetMikey.Helper.formatRecipients @model.get('recipients')

  formatDate: =>
    MeetMikey.Helper.formatDate @model.get('sentDate')