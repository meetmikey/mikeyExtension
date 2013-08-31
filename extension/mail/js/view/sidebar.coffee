resourceButtonsTemplate = """
  <div class="sidebar-buttons-wrapper">
    <div class="sidebar-buttons">
      <div class="mm-favorite" {{#if deleting}}style="opacity:0.1"{{/if}}>
        <div class="mm-download-tooltip" data-toggle="tooltip" title="Star">
          <div id="mm-sidebar-favorite-{{cid}}" class="sidebar-icon favorite{{#if isFavorite}}On{{/if}}"></div>
        </div>
      </div>
      <div class="mm-like" {{#if deleting}}style="opacity:0.1"{{/if}}>
        <div class="mm-download-tooltip" data-toggle="tooltip" title="Like">
          <div id="mm-sidebar-like-{{cid}}" class="sidebar-icon like{{#if isLiked}}On{{/if}}"></div>
        </div>
      </div>
    </div>
  </div>
"""

attachmentTemplate = """
  <div class="resource sidebar-file {{#if hasMoreThanThreeResources}}many{{/if}}" data-cid="{{cid}}" data-type="attachment">

    <img class="sidebar-file-icon mm-open-resource" src="{{iconUrl}}">
    <div class="sidebar-item-title mm-open-resource">{{filename}}</div>
    <div class="sidebar-size">{{size}}</div>
    """ + resourceButtonsTemplate + """

  </div>
"""

imageTemplate = """
  <div class="resource sidebar-image {{#if hasMoreThanThreeResources}}many{{/if}}" data-cid="{{cid}}" data-type="image">

    <div class="image mm-open-resource"><img class="sidebar-inner" src="{{image}}"></div>
    <div class="sidebar-item-title mm-open-resource">{{filename}}</div>
    """ + resourceButtonsTemplate + """

  </div>
"""

linkTemplate = """
  <div class="resource sidebar-link {{#if hasMoreThanThreeResources}}many{{else}}{{#unless summary}}many{{/unless}}{{/if}}" data-cid="{{cid}}" data-type="link">
   
    <img class="sidebar-favicon" src="{{faviconURL}}"></img>
    <div class="sidebar-item-title"><a href="#" class="mm-open-resource">{{title}}</a></div>
    <div class="sidebar-url"><a href="#" class="mm-open-resource">{{url}}</a></div>
    """ + resourceButtonsTemplate + """
    <div class="sidebar-link-preview mm-open-resource">
      {{#if image}}
        <div class="sidebar-link image"><img class="sidebar-inner" src="{{image}}"></div>
      {{/if}}
      {{#if summary}}
        <div class="sidebar-summary {{#unless image}}no-image{{/unless}}">{{summary}}</div>
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
  rapportiveContainerSelector: MeetMikey.Constants.Selectors.sidebarRapportiveContainer

  injectionCount: 0
  maxInjectionCount: 20

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
      @setupDOMListener()
      $('.mm-download-tooltip').tooltip placement: 'top'
    else
      @$el.hide()

  setupDOMListener: (renew) =>
    if @listenElement and not renew
      return
    if @listenElement
      @listenElement.off 'DOMSubtreeModified'
      @listenElement = null
    element = $(@rapportiveContainerSelector)
    if not element or not element.length
      element = $(@containerSelector)
    if element and element.length
      @listenElement = element.parent().parent()
      @listenElement.off 'DOMSubtreeModified'
      @listenElement.on 'DOMSubtreeModified', _.debounce( @domSubtreeModified, 500 )

  teardown: =>
    if @listenElement
      @listenElement.off 'DOMSubtreeModified'

  domSubtreeModified: (event) =>
    @pageNavigationEvent event

  renderTemplateAndDelegateEvents: () =>
    @renderTemplate()
    @delegateEvents()

  toggleFavoriteEvent: (event) =>
    event.preventDefault()
    model = @getModelFromEvent event
    elementId = '#mm-sidebar-favorite-' + model.cid
    MeetMikey.Helper.FavoriteAndLike.toggleFavorite model, elementId, 'sidebar'

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

  toggleLikeEvent: (event) =>
    event.preventDefault()
    model = @getModelFromEvent event
    elementId = '#mm-sidebar-like-' + model.cid
    MeetMikey.Helper.FavoriteAndLike.toggleLike model, elementId, 'sidebar'

  pageNavigationEvent: =>
    console.log 'pageNavigationEvent'
    if not @inThread()
      return
    if $('#mm-sidebar-container') and $('#mm-sidebar-container').length and $('#mm-sidebar-container').is(':visible')
      return
    @injectContainer () =>
      @getResources () =>
        @render()

  checkForRapportive: () =>
    if MeetMikey.Globals.usingRapportive
      return
    rapportiveElement = $(@rapportiveContainerSelector)
    if rapportiveElement and rapportiveElement.length
      console.log 'isRapportive!'
      MeetMikey.Globals.usingRapportive = true

  injectContainer: (callback) =>
    console.log 'injectContainer'
    @checkForRapportive()
    if @injectionCount > @maxInjectionCount
      console.log 'too many injections, giving up'
      return
    @setupDOMListener true
    if not @listenElement
      console.log 'no dom listener, trying again soon'
      setTimeout @pageNavigationEvent, 50

    @injectionCount++

    if $('#mm-sidebar-container') and $('#mm-sidebar-container').length
      $('#mm-sidebar-container').remove()
    element = '<div id="mm-sidebar-container" class="mm-container"></div>'
    selector = @containerSelector
    if MeetMikey.Globals.usingRapportive
      selector = @rapportiveContainerSelector

    MeetMikey.Helper.DOMManager.waitAndFind selector, (containerElement) =>
      if not containerElement or not containerElement.length
        console.log 'no container element'
        return
      console.log 'injecting into container!'
      MeetMikey.Helper.DOMManager.injectInto selector, element, () =>
        @$el = $('#mm-sidebar-container')
        callback()

  getResources: (callback) =>
    threadHex = MeetMikey.Helper.Url.getThreadHex()
    if not threadHex
      return
    MeetMikey.Helper.callAPI
      url: 'resource/thread/' + threadHex
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
      currentTab: 'sidebar'
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
    @sidebarImageCarouselModal.setImageModelsCollection @imagesCollection
    @sidebarImageCarouselModal.render()
    @sidebarImageCarouselModal.activateModel model