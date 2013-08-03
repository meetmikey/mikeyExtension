class LinkDecorator
  httpRegex: /https?:\/\/(.+)/
  googleDocRegex: /.*docs\.google\.com.*/

  decorate: (model) =>
    object = {}
    object.title = model.get('title') ? model.get('url')
    object.summary = model.get('summary')
    object.image = model.get('image')
    object.msgHex = model.get('gmMsgHex')
    object.url = model.get 'url'
    object.displayUrl = @formatUrl model
    object.from = @formatSender model
    object.to = @formatRecipients model
    object.sentDate = @formatDate model
    object.faviconURL = MeetMikey.Helper.getFaviconURL(model.get('resolvedURL') ? model.get('url'))
    object.isGoogleDoc = @isGoogleDoc model
    object.cid = model.cid
    object.isFavorite = model.get 'isFavorite'
    object.deleting = model.get('deleting')
    object.isLiked = model.get 'isLiked'

    object

  formatRecipients: (model) =>
    MeetMikey.Helper.formatRecipients model.get('recipients')

  formatSender: (model) =>
    MeetMikey.Helper.formatSender model.get('sender')

  formatDate: (model) =>
    MeetMikey.Helper.formatDate model.get('sentDate')

  formatUrl: (model) =>
    @stripHttp model.get('url')

  stripHttp: (url) =>
    match = url.match @httpRegex
    if match?
      match[1]
    else
      url

  isGoogleDoc: (model) =>
    url = model.get('resolvedURL') ? model.get('url')
    match = url.match @googleDocRegex
    match?

MeetMikey.Decorator.Link = new LinkDecorator()
