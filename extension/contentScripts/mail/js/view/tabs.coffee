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
</ul>
"""

class MeetMikey.View.Tabs extends MeetMikey.View.Base
  template: Handlebars.compile(template)

  events:
    'click li': 'tabClick'

  postRender: =>
    width = $('.nH').width()
    $('.mikey-tabs').css 'width':width
    $(window).resize ->
      width = $('.nH').width();
      $('.mikey-tabs').css 'width':width

  tabClick: (e) =>
    e.preventDefault()
    target = $(e.currentTarget)
    @$('.mikey-tab').removeClass 'active'
    target.addClass 'active'
    tab = target.attr('data-mm-tab')
    @trigger('clicked:tab', tab)
