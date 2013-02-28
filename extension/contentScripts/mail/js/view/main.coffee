class MeetMikey.View.Main extends MeetMikey.View.Base
  subViews:
    'tabs':
      viewClass: MeetMikey.View.Tabs
      selector: '#mm-tabs-container'
    'inbox':
      viewClass: MeetMikey.View.Inbox
      selector: '#mm-container'
      args: {fetch: true}
    'search':
      viewClass: MeetMikey.View.Search
      selector: 'body'
    'sidebar':
      viewClass: MeetMikey.View.Sidebar
      selector: '.nM[role=navigation]'

  preInitialize: =>
    @injectInboxContainer()
    @injectTabBarContainer()
    @setLayout @detectLayout()

  postInitialize: =>
    @subView('sidebar').on 'clicked:inbox', @showEmailTab
    @subView('tabs').on 'clicked:tab', @subView('inbox').showTab
    @subView('inbox').on 'updateTabCount', @subView('tabs').updateTabCount

  teardown: =>
    @subViews('sidebar').off 'clicked:inbox'

  detectLayout: =>
    'compact'

  setLayout: (layout='compact') =>
    @$el.addClass layout

  injectInboxContainer: =>
    target = @$(@options.inboxTarget)
    target.before $('<div id="mm-container" class="mm-container"></div>')

  injectTabBarContainer: =>
    $('[id=":ro"] .nH.aqK').append $('<div id="mm-tabs-container"></div>')

  showEmailTab: =>
    @subView('tabs').setActiveTab 'email'
    @subView('inbox').showTab 'email'

  render: =>
    @renderSubviews()


