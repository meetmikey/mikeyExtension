class MeetMikey.View.Main extends MeetMikey.View.Base
  subViews:
    'tabs':
      viewClass: MeetMikey.View.Tabs
      selector: '#mm-tabs-container'
    'inbox':
      viewClass: MeetMikey.View.Inbox
      selector: '#mm-container'
      args: {fetch: true, name: 'main'}
    'search':
      viewClass: MeetMikey.View.Search
      selector: '.no .nH.nn'
      args: {name: 'search', render: false, renderChildren: false}
    'sidebar':
      viewClass: MeetMikey.View.Sidebar
      selector: '.nM[role=navigation]'
      args: {render: false}

  preInitialize: =>
    @injectInboxContainer()
    @injectTabBarContainer()
    @setLayout @detectLayout()
    @options.render = false

  postInitialize: =>
    @subView('sidebar').on 'clicked:inbox', @showEmailTab
    @subView('tabs').on 'clicked:tab', @subView('inbox').showTab
    @subView('inbox').on 'updateTabCount', @subView('tabs').updateTabCount

  preRender: =>

  postRender: =>

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
