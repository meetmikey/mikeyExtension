template = """
    <ul id="mm-tabs"></ul>
    <div id="mm-attachments-tab" style="display: none;">
    </div>
"""

class MeetMikey.View.Main extends MeetMikey.View.Base
  template: Handlebars.compile(template)

  subViews:
    'tabs':
      view: MeetMikey.View.Tabs
      selector: '#mm-tabs'
    'attachments':
      view: MeetMikey.View.Attachments
      selector: '#mm-attachments-tab'

  tabs:
    email: '.UI'
    attachments: '#mm-attachments-tab'

  postRender: =>
    contentSelector = _.values(@tabs).join(', ')
    @subView('tabs').on 'clicked:tab', (tab) =>
      $(contentSelector).hide()
      $(@tabs[tab]).show()

  teardown: =>
    @subView('tabs').off 'clicked:tab'
