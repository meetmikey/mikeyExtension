class MeetMikey.View.Sidebar extends MeetMikey.View.Base
  linkSelector: MeetMikey.Constants.Selectors.sideBarLink
  renderSelf: false

  preInitialize: =>
    @events["click #{@linkSelector}"] = 'showInbox'

  events: {}

  showInbox: =>
    @trigger 'clicked:inbox'
