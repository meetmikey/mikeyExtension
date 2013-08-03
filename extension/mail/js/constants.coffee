_.extend MeetMikey.Constants,
  env: 'local'
  imgPath: 'mail/img'
  mixpanelId: '4025d8a58a875ce9a39db05bcf86fd71'
  stripeKeyTest: 'pk_test_xkrclY7n0l6KbnAmG2huBZzK'
  stripeKeyLive: 'pk_live_XVTbzJMXFGaHrDYQvmbu0zgM'
  mixpanelOff: false
  piwikOff: false
  googleAnalyticsOff: false
  pollDelay: 60*1000
  onboardCheckPollDelay: 10*1000
  msPerDay: 1000 * 60 * 60 * 24
  paginationSize: 50
  imagePaginationSize: 20
  deleteDelay: 8000
  basicPlanPrice: '3'
  basicPlanNumAccounts: 1
  basicPlanDays: '365'
  proPlanPrice: '9'
  proPlanDays: 'Unlimited'
  proPlanNumAccounts: 1
  teamPlanPrice: '30'
  teamPlanDays: 'Unlimited'
  teamPlanNumAccounts: 5
  enterprisePlanDays: 'Unlimited'
  enterprisePlanNumAccounts: '10+'
  extensionVersion: chrome.runtime.getManifest()?.version
  extensionId: chrome.i18n.getMessage("@@extension_id")
  chromeStoreReviewURL: 'https://chrome.google.com/webstore/detail/mikey-for-gmail/pfbeimpckikjpnjhcbpikdjnelnblhnn/reviews'

  APIUrls:
    local: "https://local.meetmikey.com"
    development: "https://dev.meetmikey.com"
    production: "https://api.meetmikey.com"

  Selectors:
    # selector that contains controls above inbox where we inject tabs
    #tabsContainer: '[id=":ro"] [gh="tm"]'
    tabsContainer: '[gh="tm"]'

    # selector that the inbox should be inserted before
    inboxContainer: '.BltHke.nH.oy8Mbf[role=main] .UI'

    # selector for all email views in the dom
    allInboxes: '.UI'

    # top search bar container
    searchBar: '#gbqf'

    # sidebar (with inbox, etc)
    sideBar: '.nM[role=navigation]'

    # contains most of the gmail dom
    topLevel: '.no .nH.nn'

    # table cell we use to sniff out the view layout (cozy, etc)
    tableCell: '.xY'

    # container that contains the content of the page (inbox, search results, etc)
    contentContainer: '.AO'

    # the element that is used to measure the width of the inbox
    widthElem: '.nH.nn > .nH > .nH'

    # links on the sidebar, inbox, starred, etc
    sideBarLink: '.aim'

    # the non-selected (normal) text in the sidebar
    sideBarText: ":not(.nZ) > div > div > .nU > .n0"

    # the text found in the inbox on read messages
    inboxReadText: ".yO"

    # the text found in the inbox on unread messages
    inboxUnreadText: ".zE"

    # selector on which the button colors are defined
    buttonColor: '.G-atb .T-I-ax7'

    # text for gmail dropdown below logo
    gmailDropdownText: '.akh[gh="pb"] span'

    # element that contains the user's email address
    userEmail: '#gbmpdv .gbps2'

    # gmail's pagination controls
    gmailPagination: '.Cr.aqJ > .ar5.J-J5-Ji'

    # inner container that scrolls
    scrollContainer: '[id=":4"]'

    # inner container that scrolls
    scrollContainer2: '[id=":rp"]'

    # nav bar at very top of viewport
    navBar: '#gbzc'

    mikeyDropdown: ''

    # bar containing pagination for app search
    appsSearchControl: '.Wc'

    # table containing app search stuff
    appsSearchTable: '.F.cf.zt'

    # bar containing search only docs/sites
    appsSearchOnlyDocs: '.G-MI.D.E.Qi'

    # bar containing controls above inbox
    inboxControlsContainer: ".G-atb"

    # where multiple inbox container should be injected
    multipleInboxContainer: "[id=':2']"

    # where multiple inbox container should be injected
    multipleInboxContainer2: "[id=':rr']"


    # where multiple inbox tabs should be injected
    multipleInboxTabsContainer: '[id=":5"]'

    # where multiple inbox tabs should be injected
    multipleInboxTabsContainer2: '[id=":ro"]'

    # existence of gmail tabs
    gmailTabsSelector: '.aKh'

    previewPaneSelector: '.apJ'

  MikeyTeamUserIds: [
      '51425e20a8a4db7207000006'
    , '5153edd7a66e972a10000005'
    , '5142ac686a9290970a00000a'
    , '514265596a9290970a000007'
    , '51425eb6a8a4db7207000007'
    , '514266e16a9290970a000008'
    , '5146c99d32a3828c41000005'
    , '5147afc4f287efc831000005'
    , '515b46f4abc4000e2a000010'
    , '515b8b230c0bee4a7b00000d'
    , '516dff12676a40d77400000f'
    , '5179a7af83bd33ce1d000009'
    , '51c8e009986bebf622001158'
    , '51c8df87876ece973f000e3a'
    , '51c8c575086058b13c00013d'
    , '51c8bdc3e942e2303b013ed0'
  ]
