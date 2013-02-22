template = """
    <div id="mm-tabs"></div>
    <div id="mm-attachments-tab" style="display: none;"></div>
    <div id="mm-links-tab" style="display: none;"></div>
"""

class MeetMikey.View.Inbox extends MeetMikey.View.Base
  template: Handlebars.compile(template)

  subViews:
    'tabs':
      view: MeetMikey.View.Tabs
      selector: '#mm-tabs'
    'attachments':
      view: MeetMikey.View.Attachments
      selector: '#mm-attachments-tab'
      args: {fetch: true}
    'links':
      view: MeetMikey.View.Links
      selector: '#mm-links-tab'
      args: {fetch: true}

  tabs:
    email: '.UI'
    attachments: '#mm-attachments-tab'
    links: '#mm-links-tab'

  postRender: =>
    @subView('tabs').on 'clicked:tab', @showTab
    @bindCountUpdate('attachments')
    @bindCountUpdate('links')

  changeTab: (tab) =>
    @subView('tabs').setActiveTab tab
    @showTab tab

  showTab: (tab) =>
    contentSelector = _.values(@tabs).join(', ')
    $(contentSelector).hide()
    $(@tabs[tab]).show()

  bindCountUpdate: (tab) =>
    @subView(tab).collection.on 'reset add remove', (collection) =>
      @subView('tabs').updateTabCount tab, collection.length

  teardown: =>
    @subView('tabs').off 'clicked:tab'
