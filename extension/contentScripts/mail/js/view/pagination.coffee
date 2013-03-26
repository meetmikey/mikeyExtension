template = """
  <div class="pagination-wrapper" style="display: {{display}};">
  <div class="arrow-buttons">

       <div class="page-button forward next-page">
        <div class="arrow" style="background: url({{arrowSprite}}) -42px -21px no-repeat">
        </div>
      </div>

      <div class="page-button back prev-page">
        <div class="arrow" style="background: url({{arrowSprite}}) -21px -21px no-repeat">
        </div>
      </div>

  </div>

     <div class="page-count"><strong>{{start}}-{{end}}</strong> of <strong>{{size}}</strong></div>
     </div>
"""
imgPath = MeetMikey.Settings.imgPath
arrowSprite = chrome.extension.getURL "#{imgPath}/sprite_black2.png"

class MeetMikey.View.Pagination extends MeetMikey.View.Base
  template: Handlebars.compile(template)

  events:
    'click .next-page': 'nextPage'
    'click .prev-page': 'prevPage'

  page: 0
  itemsPerPage: 50

  postInitialize: =>

  getTemplateData: =>
    state = @state?.getStateData() ? {}
    _.extend state, arrowSprite: arrowSprite, display: @getDisplay()

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
