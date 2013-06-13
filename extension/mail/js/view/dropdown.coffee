template = """
	<li class="dropdown gbt" id="mikeyDropdown">
    <a class="dropdown-toggle" id="drop4" role="button" data-toggle="dropdown" href="#">Mikey <span class="mm-carat"></span></a>
    <ul id="menu1" class="dropdown-menu mm-menu" role="menu" aria-labelledby="drop4">
      <li><a tabindex="-1" href="http://mikey.uservoice.com">Suggest a feature</a></li>
      <li><a tabindex="-1" href="mailto:support@mikeyteam.com">Mikey support</a></li>
      <li><a tabindex="-1" href="#" class="toggle-mikey">{{toggleAction}} Mikey</a></li>
      {{#if showGetMoreDays}}
      <li class="divider"></li>
      <li><a tabindex="-1" href="#" class="get-more-link"><!-- <div class="index-status">{{mailProcessedDays}}/{{mailTotalDays}}-->Get more Mikey</a></li>
      {{/if}}
    </ul>
  </li>
"""

class MeetMikey.View.Dropdown extends MeetMikey.View.Base
  template: Handlebars.compile(template)

  events:
    'click .toggle-mikey': 'toggleMikey'
    'click .get-more-link': 'openGetMoreModal'

  getTemplateData: =>
    object = {}
    object.toggleAction = if MeetMikey.Helper.OAuth.isEnabled() then 'Disable' else 'Enable'
    object.showGetMoreDays = MeetMikey.globalUser && ! MeetMikey.globalUser.isPremium()
    object.mailProcessedDays = MeetMikey.globalUser?.getMailProcessedDays()
    object.mailTotalDays = MeetMikey.globalUser?.getMailTotalDays()
    object

  rerender: =>
    @$('.dropdown').remove()
    @render()

  toggleMikey: (event) =>
    event.preventDefault()
    MeetMikey.Helper.OAuth.toggle()
    @rerender()

  openGetMoreModal: =>
    $('body').append $('<div id="mm-get-more-modal"></div>')
    @getMoreModal = new MeetMikey.View.GetMoreModal el: '#mm-get-more-modal'
    @getMoreModal.render()