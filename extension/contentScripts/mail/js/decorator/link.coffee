class LinkDecorator
  httpRegex: /https?:\/\/(.+)/

  decorate: (model) =>
    object = {}
    object.title = model.get('title') ? model.get('url')
    object.summary = model.get('summary')
    object.image = model.get('image')
    object.msgHex = model.get('gmMsgHex')
    object.url = model.get 'url'
    object.displayUrl = @stripHttp model.get('url')
    object.from = model.get('sender')?.name
    object.to = @formatRecipients model
    object.sentDate = @formatDate model
    object.faviconURL = MeetMikey.Helper.getFaviconURL(model.get('resolvedURL') ? model.get('url'))
    object.cid = model.cid

    object

  formatRecipients: (model) =>
    MeetMikey.Helper.formatRecipients model.get('recipients')

  formatDate: (model) =>
    MeetMikey.Helper.formatDate model.get('sentDate')

  stripHttp: (url) =>
    match = url.match @httpRegex
    if match?
      match[1]
    else
      url



MeetMikey.Decorator.Link = new LinkDecorator()
