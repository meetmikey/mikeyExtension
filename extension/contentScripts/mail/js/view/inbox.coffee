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
    'links':
      view: MeetMikey.View.Links
      selector: '#mm-links-tab'

  tabs:
    email: '.UI'
    attachments: '#mm-attachments-tab'
    links: '#mm-links-tab'

  postRender: =>
    console.log 'rendering'
    contentSelector = _.values(@tabs).join(', ')
    @subView('tabs').on 'clicked:tab', (tab) =>
      $(contentSelector).hide()
      $(@tabs[tab]).show()

  teardown: =>
    @subView('tabs').off 'clicked:tab'
