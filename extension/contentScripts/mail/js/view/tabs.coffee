template = """
<ul class="mikey-tabs">
  <li class="mikey-tab active" data-mm-tab="email">
    <a href="#">Email</a>
  </li>
  <li class="mikey-tab" data-mm-tab="attachments">
    <a href="#">
      Files <span class="mm-count"></span>
    </a>

  </li>
  <li class="mikey-tab" data-mm-tab="links">
    <a href="#">
      Links <span class="mm-count"></span>
    </a>
  </li>
  <li class="mikey-tab" data-mm-tab="images">
    <a href="#">
      Images <span class="mm-count"></span>
    </a>
  </li>
</ul>
"""

class MeetMikey.View.Tabs extends MeetMikey.View.Base
  template: Handlebars.compile(template)

  events:
    'click li': 'tabClick'

  postRender: =>
    @adjustWidth()

  adjustWidth: =>
    width = $('.nH').width()
    @$el.css 'width', width
    $(window).resize =>
      width = $('.nH').width()
      @$el.css 'width', width

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
    tab =  @$("[data-mm-tab='#{tab}']")
    tab.find(".mm-count").text "(#{ count })"
