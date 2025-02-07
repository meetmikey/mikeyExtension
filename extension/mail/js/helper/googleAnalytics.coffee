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
    ga('send', 'event', 'mikeyExtension', event);

MeetMikey.Helper.GoogleAnalytics = new GoogleAnalytics()