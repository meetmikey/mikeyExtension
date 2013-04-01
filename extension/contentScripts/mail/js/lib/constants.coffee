_.extend MeetMikey.Settings,
  env: "production"
  imgPath: 'contentScripts/mail/img'
  mixpanelId: "4025d8a58a875ce9a39db05bcf86fd71"
  APIUrls:
    local: "https://local.meetmikey.com"
    development: "https://dev.meetmikey.com"
    production: "https://api.meetmikey.com"

  Selectors:
    # selector that contains controls above inbox where we inject tabs
    tabsContainer: '[id=":ro"] [gh="tm"] .nH.aqK'

    # selector that the inbox should be inserted before
    inboxContainer: '.BltHke.nH.oy8Mbf[role=main] .UI'

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
