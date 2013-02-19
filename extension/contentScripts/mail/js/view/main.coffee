class MeetMikey.View.Main extends MeetMikey.View.Base
  subViews:
    'inbox':
      view: MeetMikey.View.Inbox
      selector: '#mm-container'
    'search':
      view: MeetMikey.View.Search
      selector: 'body'

  postInitialize: =>
    @injectInboxContainer()

  injectInboxContainer: =>
    target = @$(@options.inboxTarget)
    target.before $('<div id="mm-container"></div>')

  render: =>
    @renderSubviews()


