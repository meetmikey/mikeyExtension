class MeetMikey.Decorator.Link
  constructor: (@model) ->
    @title = @model.get 'mailCleanSubject'
    @url = @model.get 'url'
    @from = @model.get 'sender'
    @to = @formatRecipients()
    @sentDate = @formatDate()

  formatRecipients: =>
    MeetMikey.Helper.formatRecipients @model.get('recipients')

  formatDate: =>
    MeetMikey.Helper.formatDate @model.get('sentDate')
