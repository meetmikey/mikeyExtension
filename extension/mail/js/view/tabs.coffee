template = """
<div class="mikey-tabs-box">
  <table class="tabs-table">
    <tbody>
      <tr class="mikey-tabs {{disabledClass}}">
        <td href="#" class="mikey-tab active email-tab" data-mm-tab="email">
       
            <div class="tab-highlight"></div>
            <div class="tab-content">
              <div class="tab-icon"></div>
              <div class="tab-label">Email<div class="mm-count"></div></div>
            </div>
        </td>

        <td href="#" class="mikey-tab files-tab" data-mm-tab="attachments" data-placement="bottom" title="Mikey is at work. We'll let you know when your files are ready.">
       
            <div class="tab-highlight"></div>
            <div class="tab-content">
              <div class="tab-icon files-tab"></div>
              <div class="tab-label">Files<div class="mm-count"></div></div>
            </div>
        </td>

        <td href="#" class="mikey-tab links-tab" data-placement="bottom" title="Mikey is at work. We'll let you know when your links are ready." data-mm-tab="links">
       
            <div class="tab-highlight"></div>
            <div class="tab-content">
              <div class="tab-icon links-tab"></div>
              <div class="tab-label">Links<div class="mm-count"></div></div>
            </div>
        </td>

        <td href="#" class="mikey-tab images-tab" data-placement="bottom" title="Mikey is at work. We'll let you know when your images are ready." data-mm-tab="images">
       
            <div class="tab-highlight"></div>
            <div class="tab-content">
              <div class="tab-icon images-tab"></div>
              <div class="tab-label">Images<div class="mm-count"></div></div>
            </div>
        </td>

      </tr>

    </tbody>
  </table>
  <div class="mail-counts-container"></div>
</div>
"""

class MeetMikey.View.Tabs extends MeetMikey.View.Base
  template: Handlebars.compile(template)
  safeFind: MeetMikey.Helper.DOMManager.find

  disabled: false

  subViews:
    'mailCounts':
      selector: '.mail-counts-container'
      viewClass: MeetMikey.View.MailCounts
      args: {}

  events:
    'click .mikey-tab': 'tabClick'

  postRender: =>
    @adjustWidth()
    @manageTooltipDisplay()
    @manageDisabledDisplay()

  enable: =>
    @disabled = false
    @manageTooltipDisplay()
    @manageDisabledDisplay()

  disable: =>
    @disabled = true
    @manageTooltipDisplay()
    @manageDisabledDisplay()

  adjustWidth: =>
    @setWidth()
    $(window).resize @setWidth        

  setWidth: =>
    selector = MeetMikey.Constants.Selectors.widthElem
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

    if MeetMikey.Globals.gmailTabs && tab is 'email'
      $(MeetMikey.Constants.Selectors.gmailTabsSelector).show()
    else if MeetMikey.Globals.gmailTabs
      $(MeetMikey.Constants.Selectors.gmailTabsSelector).hide()

  updateTabCount: (tab, count) =>
    tabElement = @$("[data-mm-tab='#{tab}']")
    tabElement.find(".mm-count").text "#{ count }"
    tabElement.find(".mm-count").addClass 'displayed'

  trackTabEvent: (tab) =>
    return if MeetMikey.Globals.tabState is tab or tab is 'email'
    MeetMikey.Helper.Analytics.trackEvent 'tabChange',
      search: @options.search, tab: tab

  manageTooltipDisplay: =>
    method = if @disabled then 'enable' else 'disable'
    @$('.mikey-tab').tooltip(method)

  manageDisabledDisplay: =>
    method = if @disabled then 'addClass' else 'removeClass'
    @$('.mikey-tabs')[method] 'tabs-disabled'