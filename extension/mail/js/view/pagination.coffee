imgPath = MeetMikey.Constants.imgPath
arrowSprite = chrome.extension.getURL "#{imgPath}/sprite.png"
template = """
  <div class="pagination-wrapper" style="display: {{display}};">
  <div class="arrow-buttons">

       <div class="page-button right-box next-page {{nextPageClass}}">
        <div class="forward arrow" style="background-image: url(#{arrowSprite})">
        </div>
      </div>

      <div class="page-button left-box prev-page {{prevPageClass}}">
        <div class="back arrow" style="background-image: url(#{arrowSprite})">
        </div>
      </div>

  </div>

     <div class="page-count"><strong>{{start}}-{{end}}</strong> of <strong>{{size}}</strong></div>
     </div>
"""

class MeetMikey.View.Pagination extends MeetMikey.View.Base
  template: Handlebars.compile(template)

  events:
    'click .next-page': 'nextPage'
    'click .prev-page': 'prevPage'

  page: 0
  itemsPerPage: 50

  postInitialize: =>

  getTemplateData: =>
    data = @state?.getStateData() ? {}
    data.display = @getDisplay()
    data.prevPageClass = if data.firstPage then 'disable' else ''
    data.nextPageClass = if data.lastPage then 'disable' else ''

    data

  setState: (state) =>
    @resetState() if @state?
    @state = state
    @listenTo @state, 'change:page', @render if @state?
    @render()

  resetState: =>
    @state.set 'page', 0
    @stopListening @state, 'change:page'

  nextPage: =>
    @state.nextPage()
    @trackNextPageEvent()

  prevPage: =>
    @state.prevPage()
    @trackPrevPageEvent()

  trackNextPageEvent: =>
    MeetMikey.Helper.Mixpanel.trackEvent 'nextPage',
      currentTab: MeetMikey.Globals.tabState, page: @page

  trackPrevPageEvent: =>
    MeetMikey.Helper.Mixpanel.trackEvent 'prevPage',
      currentTab: MeetMikey.Globals.tabState, page: @page

  getDisplay: =>
    tab = MeetMikey.Globals.tabState
    method = if (tab is 'email' or tab is 'images') then 'none' else 'block'
