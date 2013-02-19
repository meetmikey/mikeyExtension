class MeetMikey.View.Sidebar extends MeetMikey.View.Base
  renderSelf: false

  events:
    'click [id=":ag"]': 'showInbox'

  showInbox: =>
    @trigger 'clicked:inbox'
    console.log 'inbox triggered'

  postInitialize: =>
