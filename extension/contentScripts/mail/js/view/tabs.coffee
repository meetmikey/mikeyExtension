template = """
<ul class="mikey-tabs">
  <li class="mikey-tab active" data-mm-tab="email">
    <a href="#">Email</a>
  </li>
  <li class="mikey-tab" data-mm-tab="attachments">
    <a href="#">Files</a>
  </li>
  <li class="mikey-tab" data-mm-tab="links">
    <a href="#">Links</a>
  </li>
  <li class="mikey-tab" data-mm-tab="images">
    <a href="#">Images</a>
  </li>
</ul>
"""

class MeetMikey.View.Tabs extends MeetMikey.View.Base
  template: Handlebars.compile(template)

  events:
    'click li': 'tabClick'

  postRender: =>
    width = $('.nH').width()
    @$('.mikey-tabs').css 'width', width
    $(window).resize =>
      width = $('.nH').width()
      @$('.mikey-tabs').css 'width', width

  setActiveTab: (tab) =>
    @$('.mikey-tab').removeClass 'active'
    @$(".mikey-tab[data-mm-tab='#{tab}']").addClass 'active'

  tabClick: (e) =>
    e.preventDefault()
    target = $(e.currentTarget)
    tab = target.attr('data-mm-tab')
    @setActiveTab tab
    @trigger('clicked:tab', tab)
