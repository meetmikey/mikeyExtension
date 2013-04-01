class ThemeManager
  inboxReadTextSelector: MeetMikey.Settings.Selectors.inboxReadText
  inboxUnreadTextSelector: MeetMikey.Settings.Selectors.inboxUnreadText

  $body: $('body')

  setup: =>
    @setLayout @detectLayout()
    @setTheme @detectTheme()

  setLayout: (layout='compact') =>
    @$body.addClass layout

  setTheme: (themeOpts) =>
    classes = _.values(themeOpts).join ' '
    console.log themeOpts
    @$body.addClass classes

  detectLayout: =>
    $elem = $(MeetMikey.Settings.Selectors.tableCell)
    padding = parseFloat $elem.css('padding-top')

    if padding < 4.5
      'compact'
    else if 8.5 <= padding
      'comfortable'
    else
      'cozy'

  detectTheme: =>
    color = if @colorIsLight(@getTextColor()) then 'light' else 'dark'
    boxColor = if @colorIsLight(@getInboxTextColor()) then 'dark-blocks' else 'light-blocks'
    buttonColor = if @colorIsLight(@getButtonTextColor()) then 'light-buttons' else 'dark-buttons'

    {color, boxColor, buttonColor}

  getTextColor: =>
    $(MeetMikey.Settings.Selectors.sideBarText).css 'color'

  getInboxTextColor: =>
    $(@inboxReadTextSelector).css('color') ? $(@inboxUnreadTextSelector).css('color')

  getButtonTextColor: =>
    $(MeetMikey.Settings.Selectors.buttonColor).css 'background-image'

  parseRGB: (str) =>
    [match, red, green, blue] = str.match /\((\d+), (\d+), (\d+)/

    {red, green, blue}

  brightnessRGB: (colors) =>
    numbers = _.chain(colors).values().map (color) -> parseInt color, 10
    sum = _.reduce numbers.value(), (memo, num) -> memo + num
    sum / 3

  colorIsLight: (str) =>
    127.5 < @brightnessRGB @parseRGB(str)


MeetMikey.Helper.Theme = new ThemeManager()
