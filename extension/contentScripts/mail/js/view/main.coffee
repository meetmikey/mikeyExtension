template = """
    <ul id="mm-tabs"></ul>
    <div id="mm-files-tab" style="display: none;">
      MIKEY TAB IS HERE!!!!!!!
    </div>
"""

class MeetMikey.View.Main extends MeetMikey.View.Base
  template: Handlebars.compile(template)

  subViews:
    'tabs':
      view: MeetMikey.View.Tabs
      selector: '#mm-tabs'

  tabs:
    email: '.UI'
    files: '#mm-files-tab'

  postRender: =>
    contentSelector = _.values(@tabs).join(', ')
    console.log(contentSelector)
    @subView('tabs').on 'clicked:tab', (tab) =>
      $(contentSelector).hide()
      $(@tabs[tab]).show()

  teardown: =>
    @subView('tabs').off 'clicked:tab'
