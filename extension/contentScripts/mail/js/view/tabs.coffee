template = """
<ul class="mikey-tabs {{disabledClass}}">
  <li class="mikey-tab active" data-mm-tab="email">
    <a href="#">Email</a>
  </li>
  <li class="mikey-tab" data-placement="bottom" title="Mikey is at work. We'll let you know when your files are ready." data-mm-tab="attachments">
    <a href="#">
      Files <span class="mm-count"></span>
    </a>
  </li>
  <li class="mikey-tab" data-placement="bottom" title="Mikey is at work. We'll let you know when your links are ready." data-mm-tab="links">
    <a href="#">
      Links <span class="mm-count"></span>
    </a>
  </li>
  <li class="mikey-tab" data-placement="bottom" title="Mikey is at work. We'll let you know when your images are ready." data-mm-tab="images">
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

  disabled: false

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
    @manageTooltipDisplay()

  enable: =>
    @disabled = false
    @$('.mikey-tabs').removeClass 'tabs-disabled'
    @manageTooltipDisplay()

  disable: =>
    @disabled = true
    @$('.mikey-tabs').addClass 'tabs-disabled'
    @manageTooltipDisplay()

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
    return if @disabled
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

  manageTooltipDisplay: =>
    method = if @disabled then 'enable' else 'disable'
    @$('.mikey-tab').tooltip(method)
