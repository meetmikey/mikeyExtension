chrome.extension.getURL MeetMikey.Constants.imgPath + '/' + @mikeyIcon


attachmentTemplate = """
  <br/>
  <br/>
  I'm an attachment!
  <br/>

  <img src="{{iconUrl}}">
  <a href="{{url}}" target="_blank">{{filename}}</a>
  <br/>
"""

imageTemplate = """
  <br/>
  <br/>
  I'm an image!
  <br/>

  <img src="{{image}}" style="max-width:200px;max-height:150px;">
  {{filename}}
  <br/>
"""

linkTemplate = """
  <br/>
  <br/>
  I'm a link!
  <br/>

  {{title}}
  <a href="{{url}}">{{url}}</a>
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

  postInitialize: =>
    @attachmentsCollection = new MeetMikey.Collection.Attachments()
    @attachmentsCollection.on 'reset', @renderTemplate
    @imagesCollection = new MeetMikey.Collection.Images()
    @imagesCollection.on 'reset', @renderTemplate
    @linksCollection = new MeetMikey.Collection.Links()
    @linksCollection.on 'reset', @renderTemplate

  postRender: =>
    if @inThread()
      @$el.show()
    else
      @$el.hide()

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
    console.log 'threadHex: ', threadHex
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
      console.log 'handleGetResourceResponse, resources: ', resources

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