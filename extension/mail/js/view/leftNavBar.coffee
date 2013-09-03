class MeetMikey.View.LeftNavBar extends MeetMikey.View.Base
  linkSelector: MeetMikey.Constants.Selectors.leftNavBarLink
  renderSelf: false

  preInitialize: =>
    @events["click #{@linkSelector}"] = 'showInbox'

  events: {}

  showInbox: =>
    @trigger 'clicked:inbox'
