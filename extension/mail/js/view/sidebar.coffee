resourceButtonsTemplate = """
  <div class="sidebar-buttons-wrapper">
    <div class="sidebar-buttons">
      <div class="mm-favorite" {{#if deleting}}style="opacity:0.1"{{/if}}>
        <div id="mm-sidebar-favorite-{{cid}}" class="sidebar-icon favorite{{#if isFavorite}}On{{/if}}"></div>
      </div>
      <div class="mm-like" {{#if deleting}}style="opacity:0.1"{{/if}}>
        <div id="mm-sidebar-like-{{cid}}" class="sidebar-icon like{{#if isLiked}}On{{/if}}"></div>
      </div>
    </div>
  </div>
"""

attachmentTemplate = """
  <div class="resource sidebar-file {{#if hasMoreThanThreeResources}}many{{/if}}" data-cid="{{cid}}" data-type="attachment">

    <img class="sidebar-file-icon" src="{{iconUrl}}">
    <div class="sidebar-item-title"><a href="#" class="mm-open-resource">{{filename}}</a></div>
    <div class="sidebar-size">{{size}}</div>
    """ + resourceButtonsTemplate + """

  </div>
"""

imageTemplate = """
  <div class="resource sidebar-image {{#if hasMoreThanThreeResources}}many{{/if}}" data-cid="{{cid}}" data-type="image">

    <a href="#" class="mm-open-resource"><div class="image"><img class="sidebar-inner" src="{{image}}"></div></a>
    <div class="sidebar-item-title"><a href="#" class="mm-open-resource">{{filename}}</a></div>
    """ + resourceButtonsTemplate + """

  </div>
"""

linkTemplate = """
  <div class="resource sidebar-link {{#if hasMoreThanThreeResources}}many{{else}}{{#unless summary}}many{{/unless}}{{/if}}" data-cid="{{cid}}" data-type="link">
   
    <img class="sidebar-favicon" src="{{faviconURL}}"></img>
    <div class="sidebar-item-title"><a href="#" class="mm-open-resource">{{title}}</a></div>
    <div class="sidebar-url"><a href="#" class="mm-open-resource">{{url}}</a></div>
    """ + resourceButtonsTemplate + """
    <div class="sidebar-link-preview">
      <div class="sidebar-link image"><img class="sidebar-inner" src="{{image}}"></div>
      {{#if summary}}
        <div class="sidebar-summary">{{summary}}</div>
      {{/if}}
    </div>

  </div>
"""

template = """
{{#if threadHasAnyResources}}
  <div class="mm-sidebar-header">From this thread:</div>
  <div class="mm-sidebar">
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
  </div>
{{/if}}
"""

class MeetMikey.View.Sidebar extends MeetMikey.View.Base
  template: Handlebars.compile(template)
  containerSelector: MeetMikey.Constants.Selectors.sidebarContainer

  events:
    'click .mm-favorite': 'toggleFavoriteEvent'
    'click .mm-like': 'toggleLikeEvent'
    'click .mm-open-resource': 'openResource'

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
    element = $(@containerSelector).parent().parent()
    element.off 'DOMSubtreeModified'
    element.one 'DOMSubtreeModified', @pageNavigationEvent

  renderTemplateAndDelegateEvents: () =>
    @renderTemplate()
    @delegateEvents()

  toggleFavoriteEvent: (event) =>
    event.preventDefault()
    model = @getModelFromEvent event
    @toggleFavorite model

  toggleFavorite: (model) =>
    if not model
      #console.log 'toggleFavorite, no model!'
      return
    oldIsFavorite = model.get('isFavorite')
    newIsFavorite = true
    if oldIsFavorite
      newIsFavorite = false
    model.set 'isFavorite', newIsFavorite
    @updateModelFavoriteDisplay model
    MeetMikey.Helper.trackResourceInteractionEvent 'resourceFavorite', @getResourceType(model), newIsFavorite, 'thread'
    model.putIsFavorite newIsFavorite, (response, status) =>
      if status != 'success'
        model.set 'isFavorite', oldIsFavorite
        @updateModelFavoriteDisplay model
      else
        MeetMikey.globalEvents.trigger 'favoriteOrLikeAction'

  getResourceType: (model) =>
    type = 'image'
    if model
      decoratedModel = model.decorate()
      if decoratedModel.isAttachment
        type = 'attachment'
      else if decoratedModel.isLink
        type = 'link'
    type

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

  updateModelFavoriteDisplay: (model) =>
    elementId = '#mm-sidebar-favorite-' + model.cid
    @$(elementId).removeClass 'favorite'
    @$(elementId).removeClass 'favoriteOn'
    if model.get 'isFavorite'
      @$(elementId).addClass 'favoriteOn'
    else
      @$(elementId).addClass 'favorite'

  updateModelLikeDisplay: (model) =>
    elementId = '#mm-sidebar-like-' + model.cid
    @$(elementId).removeClass 'like'
    @$(elementId).removeClass 'likeOn'
    if model.get 'isLiked'
      @$(elementId).addClass 'likeOn'
    else
      @$(elementId).addClass 'like'

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
          @updateModelLikeDisplay model
          MeetMikey.Helper.trackResourceInteractionEvent 'resourceLike', @getResourceType(model), true, 'thread'
          model.putIsLiked true, (response, status) =>
            if status != 'success'
              model.set 'isLiked', false
              @updateModelLikeDisplay model
            else
              MeetMikey.globalEvents.trigger 'favoriteOrLikeAction'

  pageNavigationEvent: =>
    if @inThread()
      if $('#mm-sidebar-container') and $('#mm-sidebar-container').is(':visible')
        return
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
    models = @getModels()
    threadHasAnyResources = false
    if models and models.length > 0
      threadHasAnyResources = true
    if models and models.length > 3
      _.each models, (model) =>
        model.hasMoreThanThreeResources = true


    object = {}
    object.mikeyImage = chrome.extension.getURL MeetMikey.Constants.imgPath + '/mikeyIcon120x120.png'
    object.models = models
    object.threadHasAnyResources = threadHasAnyResources
    object

  openResource: (event) =>
    model = @getModelFromEvent event
    decoratedModel = model.decorate()
    MeetMikey.Helper.trackResourceEvent 'openResource', model,
      currentTab: 'thread'
    if decoratedModel.isImage
      @openImageCarousel model
    else
      window.open decoratedModel.url

  getImages: =>
    models = @getModels()
    images = _.filter models, (model) =>
      if model.isImage
        return true
      return false
    images

  openImageCarousel: (model) =>
    $('body').append $('<div id="mm-sidebar-image-carousel"></div>')
    @sidebarImageCarouselModal = new MeetMikey.View.SidebarImageCarouselModal el: '#mm-sidebar-image-carousel'
    @sidebarImageCarouselModal.setImages @getImages()
    @sidebarImageCarouselModal.render()
    @sidebarImageCarouselModal.activateModel model