class Setup
  inboxSelector: MeetMikey.Constants.Selectors.inboxContainer
  tabsSelector: MeetMikey.Constants.Selectors.tabsContainer
  userEmailSelector: MeetMikey.Constants.Selectors.userEmail

  start: =>
    $(window).one('DOMSubtreeModified', @bootstrap)

  bootstrap: =>
    MeetMikey.Helper.BetaAccess.checkAccess @waitAndStartAuthFlow

  waitAndStartAuthFlow: =>
    MeetMikey.Helper.findSelectors @userEmailSelector, @startAuthFlow

  startAuthFlow: (target) =>
    @injectDropdown()
    MeetMikey.Helper.OAuth.checkUser (userData) =>
      if userData?
        @authorized(userData)
      else
        @injectOnboardModal()

  authorized: (userData) =>
    @checkMultipleInbox =>
      @initalizeGlobalUser userData
      @trackLoginEvent(userData)
      @waitForInbox()

  trackLoginEvent: (user) =>
    MeetMikey.Helper.Mixpanel.trackEvent 'login', _.omit(user, 'asymHash')

  initalizeGlobalUser: (data) =>
    MeetMikey.globalUser = new MeetMikey.Model.User data
    MeetMikey.Helper.Mixpanel.setUser MeetMikey.globalUser
    MeetMikey.globalUser.checkOnboard()

  checkMultipleInbox: (callback) =>
    controlSelector = MeetMikey.Constants.Selectors.inboxControlsContainer
    tabContainerSelector = MeetMikey.Constants.Selectors.multipleInboxTabsContainer
    MeetMikey.Helper.DOMManager.waitAndFind controlSelector, (target) =>
      margin = target.css 'margin-left'
      MeetMikey.Globals.multipleInbox = @multipleInbox = margin isnt "-400px" and $(tabContainerSelector).find(controlSelector)?.length == 0
      @setSelectors()
      callback @multipleInbox

  setSelectors: =>
    selectors = MeetMikey.Constants.Selectors
    if @multipleInbox
      @inboxSelector = selectors.multipleInboxContainer
      @tabsSelector = selectors.multipleInboxTabsContainer
      $('body').addClass 'multiple-inbox'
    else
      @inboxSelector = selectors.inboxContainer
      @tabsSelector = selectors.tabsContainer

  waitForInbox: =>
    inboxFound = @checkIfInInbox()
    $(window).on 'hashchange', @checkIfInInbox unless inboxFound

  inInbox: MeetMikey.Helper.Url.inInbox

  checkIfInInbox: =>
    inInbox = @inInbox()
    if inInbox
      $(window).off 'hashchange', @checkIfInInbox
      MeetMikey.Helper.DOMManager.waitAndFindAll @inboxSelector, @tabsSelector, @checkAndInjectMainView
    inInbox

  injectDropdown: =>
    return if @dropdownView?
    @dropdownView = new MeetMikey.View.Dropdown
      el: MeetMikey.Constants.Selectors.navBar, append: true
    @dropdownView.render()

  # Rename Auth modal
  injectOnboardModal: =>
    $('body').append $('<div id="mm-onboard-modal"></div>')
    view = new MeetMikey.View.OnboardModal el: '#mm-onboard-modal'
    view.render()
    view.on 'disabled', => @dropdownView.rerender()
    view.on 'authorized', (userData) =>
      @authorized(userData)
      @injectThanksModal() if MeetMikey.globalUser.get('onboarding')

  # Rename Welcome Modal
  injectThanksModal: =>
    $('body').append $('<div id="mm-thanks-modal"></div>')
    view = new MeetMikey.View.ThanksModal el: '#mm-thanks-modal'
    view.render()

  injectMainView: =>
    @mainView = new MeetMikey.View.Main el: 'body', owned: false, multipleInbox: @multipleInbox
    @mainView.render()

  checkAndInjectMainView: =>
    if @inInbox()
      @injectMainView()
    else
      @waitForInbox()


MeetMikey.Helper.Setup = new Setup()
