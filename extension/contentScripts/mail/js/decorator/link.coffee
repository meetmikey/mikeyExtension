class LinkDecorator
  decorate: (model) =>
    object = {}
    object.title = model.get('title') ? model.get('url')
    object.summary = model.get('summary')
    object.url = model.get 'url'
    object.from = model.get('sender')?.name
    object.to = @formatRecipients model
    object.sentDate = @formatDate model
    object.faviconURL = MeetMikey.Helper.getFaviconURL(model.get('resolvedURL') ? model.get('url'))

    object

  formatRecipients: (model) =>
    MeetMikey.Helper.formatRecipients model.get('recipients')

  formatDate: (model) =>
    MeetMikey.Helper.formatDate model.get('sentDate')


MeetMikey.Decorator.Link = new LinkDecorator()
