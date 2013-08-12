chrome.extension.getURL MeetMikey.Constants.imgPath + '/' + @mikeyIcon

template = """
  <div>Mikey sidebar!</div>
  <img src="{{mikeyImage}}" />
"""

class MeetMikey.View.Sidebar extends MeetMikey.View.Base
  template: Handlebars.compile(template)
  containerSelector: MeetMikey.Constants.Selectors.sidebarContainer

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
    console.log 'handleGetResourceResponse, response: ', response

  inThread: =>
    MeetMikey.Helper.Url.inThread()

  getTemplateData: =>
    object = {}
    object.mikeyImage = chrome.extension.getURL MeetMikey.Constants.imgPath + '/mikeyIcon120x120.png'
    object