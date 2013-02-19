class MeetMikey.View.Main extends MeetMikey.View.Base
  subViews:
    'inbox':
      view: MeetMikey.View.Inbox
      selector: '#mm-container'
    'search':
      view: MeetMikey.View.Search
      selector: 'body'
    'sidebar':
      view: MeetMikey.View.Sidebar
      selector: '.nM[role=navigation]'

  postInitialize: =>
    @injectInboxContainer()
    @subViews.sidebar.view.on 'clicked:inbox', =>
      @subViews.inbox.view.changeTab 'email'

  teardown: =>
    @subViews.sidebar.view.off 'clicked:inbox'


  injectInboxContainer: =>
    target = @$(@options.inboxTarget)
    target.before $('<div id="mm-container"></div>')

  render: =>
    @renderSubviews()


