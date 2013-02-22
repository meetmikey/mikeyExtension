template = """
<ul class="mikey-tabs">
  <li class="mikey-tab active" data-mm-tab="email">
    <a href="#">Email</a>
  </li>
  <li class="mikey-tab" data-mm-tab="attachments">
    <a href="#">Files (<span class="mm-count">0</span>)</a>
  </li>
  <li class="mikey-tab" data-mm-tab="links">
    <a href="#">Links (<span class="mm-count">0</span>)</a>
  </li>
  <li class="mikey-tab" data-mm-tab="images">
<<<<<<< HEAD
    <a href="#">Images (<span class="mm-count">0</span>)</a>
=======
    <a href="#">Images</a>
>>>>>>> 9be8b8660a4d9b1315bc2a077018aec2289bbf2e
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

  updateTabCount: (tab, count) =>
    console.log "setting #{tab} count to #{count}"
    @$("[data-mm-tab='#{tab}'] .mm-count").text count
