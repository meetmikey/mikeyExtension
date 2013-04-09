template = """
<ul class="mikey-tabs">
  <li class="mikey-tab active" data-mm-tab="email">
    <a href="#">Email</a>
  </li>
  <li class="mikey-tab" data-mm-tab="attachments">
    <a href="#">
      Files <span class="mm-count"></span>
    </a>

  </li>
  <li class="mikey-tab" data-mm-tab="links">
    <a href="#">
      Links <span class="mm-count"></span>
    </a>
  </li>
  <li class="mikey-tab" data-mm-tab="images">
    <a href="#">
      Images <span class="mm-count"></span>
    </a>
  </li>
</ul>
<div class="pagination-container"></div>
"""

class MeetMikey.View.Tabs extends MeetMikey.View.Base
  template: Handlebars.compile(template)
  safeFind: MeetMikey.Helper.DOMManager.find

  subViews:
    'pagination':
      selector: '.pagination-container'
      viewClass: MeetMikey.View.Pagination
      args: {}

  events:
    'click li': 'tabClick'

  postInitialize: =>
    @subView('pagination').options.render = false if @options.search

  postRender: =>
    @adjustWidth()

  adjustWidth: =>
    @setWidth()
    $(window).resize @setWidth

  setWidth: =>
    selector = MeetMikey.Settings.Selectors.widthElem
    elem = @safeFind(selector).parent().parent()
    width = elem.width()
    @$el.css 'width', width

  setActiveTab: (tab) =>
    @$('.mikey-tab').removeClass 'active'
    @$(".mikey-tab[data-mm-tab='#{tab}']").addClass 'active'

  getActiveTab: =>
    @$('.mikey-tab.active').attr('data-mm-tab')

  tabClick: (e) =>
    e.preventDefault()
    target = $(e.currentTarget)
    tab = target.attr('data-mm-tab')
    @setActiveTab tab
    @trackTabEvent tab
    @trigger('clicked:tab', tab)

  updateTabCount: (tab, count) =>
    tab =  @$("[data-mm-tab='#{tab}']")
    tab.find(".mm-count").text "(#{ count })"

  trackTabEvent: (tab) =>
    return if MeetMikey.Globals.tabState is tab or tab is 'email'
    MeetMikey.Helper.Mixpanel.trackEvent 'tabChange',
      search: @options.search, tab: tab
