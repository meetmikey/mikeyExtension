class MeetMikey.View.Sidebar extends MeetMikey.View.Base
  renderSelf: false

  events:
    'click .aim': 'showInbox'

  showInbox: =>
    @trigger 'clicked:inbox'
    console.log 'inbox triggered'

  postInitialize: =>
