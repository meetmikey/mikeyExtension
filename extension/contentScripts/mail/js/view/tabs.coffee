template = """
  <li data-mm-tab="email">
    <a href="#">Email</a>
  </li>
  <li data-mm-tab="attachments">
    <a href="#">Files</a>
  </li>
  <li data-mm-tab="links">
    <a href="#">Links</a>
  </li>
"""

class MeetMikey.View.Tabs extends MeetMikey.View.Base
  template: Handlebars.compile(template)

  events:
    'click li': 'tabClick'

  tabClick: (e) =>
    e.preventDefault()
    tab = $(e.currentTarget).attr('data-mm-tab')
    @trigger('clicked:tab', tab)
