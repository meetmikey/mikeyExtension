attachmentTemplate = """
  <br/>
  <br/>

  <div class="resource" data-cid="{{cid}}" data-type="attachment">
    I'm an attachment!
    <br/>

    <img src="{{iconUrl}}">
    <a href="{{url}}" target="_blank">{{filename}}</a>
    <div class="mm-favorite" {{#if deleting}}style="opacity:0.1"{{/if}}>
      <div class="mm-download-tooltip" data-toggle="tooltip" title="Toggle favorite">
        <div class="inbox-icon favorite{{#if isFavorite}}On{{/if}}"></div>
      </div>
    </div>

    <div class="mm-like" {{#if deleting}}style="opacity:0.1"{{/if}}>
      <div class="mm-download-tooltip" data-toggle="tooltip" title="Like">
        <div class="inbox-icon like{{#if isLiked}}On{{/if}}"></div>
      </div>
    </div>
  </div>

  <br/>
"""

imageTemplate = """
  <br/>
  <br/>

  <div class="resource" data-cid="{{cid}}" data-type="image">
    I'm an image!
    <br/>

    <img src="{{image}}" style="max-width:200px;max-height:150px;">
    {{filename}}
    <div class="mm-like" {{#if deleting}}style="opacity:0.1"{{/if}}>
      <div class="mm-download-tooltip" data-toggle="tooltip" title="Like">
        <div class="inbox-icon like{{#if isLiked}}On{{/if}}"></div>
      </div>
    </div>
  </div>

  <br/>
"""

linkTemplate = """
  <br/>
  <br/>
  <div class="resource" data-cid="{{cid}}" data-type="link">
    I'm a link!
    <br/>

    {{title}}
    <a href="{{url}}">{{url}}</a>
    {{summary}}
    <div class="mm-favorite" {{#if deleting}}style="opacity:0.1"{{/if}}>
      <div class="mm-download-tooltip" data-toggle="tooltip" title="Toggle favorite">
        <div class="inbox-icon favorite{{#if isFavorite}}On{{/if}}"></div>
      </div>
    </div>

    <div class="mm-like" {{#if deleting}}style="opacity:0.1"{{/if}}>
      <div class="mm-download-tooltip" data-toggle="tooltip" title="Like">
        <div class="inbox-icon like{{#if isLiked}}On{{/if}}"></div>
      </div>
    </div>
  </div>

  <br/>
"""

template = """
  <div>Mikey sidebar!</div>
  <img src="{{mikeyImage}}" style="max-width:20px;max-height:20px;"/>
  {{#each models}}
    {{#if isAttachment}}
      """ + attachmentTemplate + """
    {{else}}
      {{#if isImage}}
        """ + imageTemplate + """
      {{else}}
        """ + linkTemplate + """
      {{/if}}
    {{/if}}
  {{/each}}
"""

class MeetMikey.View.Sidebar extends MeetMikey.View.Base
  template: Handlebars.compile(template)
  containerSelector: MeetMikey.Constants.Selectors.sidebarContainer

  events:
    'click .mm-favorite': 'toggleFavoriteEvent'
    'click .mm-like': 'toggleLikeEvent'

  postInitialize: =>
    @attachmentsCollection = new MeetMikey.Collection.Attachments()
    @attachmentsCollection.on 'reset', @renderTemplateAndDelegateEvents

    @imagesCollection = new MeetMikey.Collection.Images()
    @imagesCollection.on 'reset', @renderTemplateAndDelegateEvents

    @linksCollection = new MeetMikey.Collection.Links()
    @linksCollection.on 'reset', @renderTemplateAndDelegateEvents

  postRender: =>
    if @inThread()
      @$el.show()
    else
      @$el.hide()
    @$el.parent().off 'DOMSubtreeModified'
    @$el.parent().one 'DOMSubtreeModified', @pageNavigationEvent

  renderTemplateAndDelegateEvents: () =>
    @renderTemplate()
    @delegateEvents()

  toggleFavoriteEvent: (event) =>
    event.preventDefault()
    model = @getModelFromEvent event
    @toggleFavorite model

  toggleFavorite: (model) =>
    if not model
      console.log 'toggleFavorite, no model!'
      return
    oldIsFavorite = model.get('isFavorite')
    newIsFavorite = true
    if oldIsFavorite
      newIsFavorite = false
    model.set 'isFavorite', newIsFavorite
    model.putIsFavorite newIsFavorite, (response, status) =>
      if status == 'success'
        MeetMikey.globalEvents.trigger 'favoriteOrLikeAction'
        @renderTemplate()
      else
        console.log 'putIsFavorite failed'

  getModelFromEvent: (event) =>
    cid = $(event.currentTarget).closest('.resource').attr('data-cid')
    resourceType = $(event.currentTarget).closest('.resource').attr('data-type')
    model = null
    if resourceType == 'attachment'
      model = @attachmentsCollection.get(cid)
    else if resourceType == 'image'
      model = @imagesCollection.get(cid)
    else
      model = @linksCollection.get(cid)
    model

  toggleLikeEvent: (event) =>
    event.preventDefault()
    model = @getModelFromEvent event
    @toggleLike model

  toggleLike: (model) =>
    if not model
      console.log 'toggleLike, no model!'
      return
    if not model.get('isLiked')
      MeetMikey.Helper.Messaging.checkLikeInfoMessaging model, (shouldProceed) =>
        if shouldProceed
          model.set 'isLiked', true
          @renderTemplate()
          model.putIsLiked true, (response, status) =>
            if status != 'success'
              @renderTemplate()
            else
              MeetMikey.globalEvents.trigger 'favoriteOrLikeAction'

  pageNavigationEvent: =>
    if @inThread()
      @injectContainer () =>
        @getResources () =>
          @render()

  injectContainer: (callback) =>
    $('#mm-sidebar-container').remove()
    element = '<div id="mm-sidebar-container" class="mm-container"></div>'
    MeetMikey.Helper.DOMManager.injectInto @containerSelector, element, () =>
      @$el = $('#mm-sidebar-container')
      callback()

  getResources: (callback) =>
    email = MeetMikey.globalUser?.get('email')
    threadHex = MeetMikey.Helper.Url.getThreadHex()
    if threadHex
      MeetMikey.Helper.callAPI
        url: 'resource/thread/' + threadHex
        type: 'GET'
        data:
          userEmail: email
        complete: (response, status) =>
          @handleGetResourceResponse response, status
          callback()
    else
      console.log 'no thread hex'

  handleGetResourceResponse: (response, status) =>
    if ( status == 'success' and response.responseText )
      try
        resources = JSON.parse response.responseText
        
        newAttachments = []
        if resources.attachments
          newAttachments = resources.attachments
        @attachmentsCollection.reset newAttachments

        newImages = []
        if resources.images
          newImages = resources.images
        @imagesCollection.reset newImages

        newLinks = []
        if resources.links
          newLinks = resources.links
        @linksCollection.reset newLinks
      catch e
        console.log 'parse error, e: ', e

  inThread: =>
    MeetMikey.Helper.Url.inThread()

  getModels: () =>
    decoratedAttachments = _.invoke(@attachmentsCollection.models, 'decorate')
    decoratedImages = _.invoke(@imagesCollection.models, 'decorate')
    decoratedLinks = _.invoke(@linksCollection.models, 'decorate')
    allModels = decoratedAttachments.concat(decoratedImages).concat(decoratedLinks)
    allModels.sort @modelSortFunction
    allModels

  modelSortFunction: (a, b) =>
    if a.rawSentDate < b.rawSentDate
      -1
    else if a.rawSentDate > b.rawSentDate
      1
    else
      0

  getTemplateData: =>
    object = {}
    object.mikeyImage = chrome.extension.getURL MeetMikey.Constants.imgPath + '/mikeyIcon120x120.png'
    object.models = @getModels()
    object