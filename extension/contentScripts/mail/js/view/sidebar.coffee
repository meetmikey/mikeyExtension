class MeetMikey.View.Sidebar extends MeetMikey.View.Base
  linkSelector: MeetMikey.Settings.Selectors.sideBarLinkSelector
  renderSelf: false

  preInitialize: =>
    @events["click #{@linkSelector}"] = 'showInbox'

  events: {}

  showInbox: =>
    @trigger 'clicked:inbox'
    console.log 'inbox triggered'
