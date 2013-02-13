template = """
<ul class="mikeyTabs">
  <li data-mm-tab="email">
    <a href="#">Email</a>
  </li>
  <li data-mm-tab="attachments">
    <a href="#">Files</a>
  </li>
</ul>
"""

class MeetMikey.View.Tabs extends MeetMikey.View.Base
  template: Handlebars.compile(template)

  events:
    'click li': 'tabClick'

  tabClick: (e) =>
    e.preventDefault()
    tab = $(e.currentTarget).attr('data-mm-tab')
    @trigger('clicked:tab', tab)
