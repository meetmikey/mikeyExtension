template = """
	<li class="dropdown gbt" id="mikeyDropdown">
    <a class="dropdown-toggle" id="drop4" role="button" data-toggle="dropdown" href="#">Mikey <span class="mm-carat"></span></a>
    <ul id="menu1" class="dropdown-menu mm-menu" role="menu" aria-labelledby="drop4">
      <li><a tabindex="-1" href="http://mikey.uservoice.com">Suggest a feature</a></li>
      <li><a tabindex="-1" href="mailto:support@mikeyteam.com">Mikey support</a></li>
      <li><a tabindex="-1" target="_blank" href="http://www.meetmikey.com/faq.html">Mikey FAQ</a></li>
      <li><a tabindex="-1" href="#" class="toggle-mikey">{{toggleAction}} Mikey</a></li>
      {{#if shouldShowDivider}}
        <li class="divider"></li>
      {{/if}}
      {{#if shouldShowShareMikey}}
        <li>
          <a tabindex="-1" href="#" class="get-more">
            {{#if isPremium}}
              Share Mikey
            {{else}}
              Get more Mikey
            {{/if}}
          </a>
        </li>
      {{/if}}
      {{#if shouldShowMyAccount}}
        <li><a tabindex="-1" href="#" class="mikey-account">My Mikey Account</a></li>
      {{/if}}
    </ul>
  </li>
"""

class MeetMikey.View.Dropdown extends MeetMikey.View.Base
  template: Handlebars.compile(template)

  events:
    'click .toggle-mikey': 'toggleMikey'
    'click .get-more': 'openGetMoreModal'
    'click .mikey-account': 'openUpgradeModal'

  postInitialize: =>
    @addGlobalUserEvent()

  addGlobalUserEvent: () =>
    if MeetMikey.globalUser
      MeetMikey.globalUser.off 'change'
      MeetMikey.globalUser.on 'change', @rerender
    @rerender()

  getTemplateData: =>
    object = {}
    object.toggleAction = if MeetMikey.Helper.OAuth.isEnabled() then 'Disable' else 'Enable'
    object.mailDaysLimit = MeetMikey.globalUser?.getDaysLimit()
    object.mailTotalDays = MeetMikey.globalUser?.getMailTotalDays()
    object.isPremium = MeetMikey.globalUser?.isPremium()
    object.shouldShowShareMikey = @shouldShowShareMikey()
    object.shouldShowMyAccount = @shouldShowMyAccount()
    object.shouldShowDivider = @shouldShowShareMikey() or @shouldShowMyAccount()
    object

  shouldShowMyAccount: =>
    if MeetMikey.globalUser &&
    ! MeetMikey.globalUser.get('isGrantedPremium')
      true
    else 
      false

  shouldShowShareMikey: =>
    if MeetMikey.globalUser &&
    ! MeetMikey.globalUser.get('onboarding') &&
    MeetMikey.globalUser.getMailTotalDays()
      true
    else 
      false

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

  openUpgradeModal: =>
    $('body').append $('<div id="mm-upgrade-modal"></div>')
    @upgradeModal = new MeetMikey.View.UpgradeModal el: '#mm-upgrade-modal'
    @upgradeModal.render()
    @upgradeModal.notifyAboutUpgradeInterest 'myAccount'