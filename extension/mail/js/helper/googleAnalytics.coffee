class GoogleAnalytics

  code: 'UA-39249462-1'
  hasSetup: false

  setup: () =>
    if ! @hasSetup
      ga('create', @code);
      @hasSetup = true

  setUser: (allProps) =>
    @setup()

  trackEvent: (event, eventProps, allProps) =>
    @setup()
    #console.log 'ga trackEvent, event: ', event
    ga('send', 'event', 'mikeyExtension', event);

MeetMikey.Helper.GoogleAnalytics = new GoogleAnalytics()