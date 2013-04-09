class ThemeManager
  inboxReadTextSelector: MeetMikey.Settings.Selectors.inboxReadText
  inboxUnreadTextSelector: MeetMikey.Settings.Selectors.inboxUnreadText

  $body: $('body')
  safeFind: MeetMikey.Helper.DOMManager.find

  setup: =>
    @setLayout @detectLayout()
    @setTheme @detectTheme()

  setLayout: (layout='compact') =>
    @$body.addClass layout

  setTheme: (themeOpts) =>
    classes = _.values(themeOpts).join ' '
    @$body.addClass classes

  detectLayout: =>
    $elem =  @safeFind MeetMikey.Settings.Selectors.tableCell
    padding = parseFloat $elem.css('padding-top')

    if padding < 4.5
      'compact'
    else if 8.5 <= padding
      'comfortable'
    else
      'cozy'

  detectTheme: =>
    return {} if @isDefaultTheme()
    color = if @colorIsLight(@getTextColor()) then 'light' else 'dark'
    boxColor = if @colorIsLight(@getInboxTextColor()) then 'dark-blocks' else 'light-blocks'
    buttonColor = if @colorIsLight(@getButtonColor()) then 'light-buttons' else 'dark-buttons'

    {color, boxColor, buttonColor}

  isDefaultTheme: =>
    color = @safeFind(MeetMikey.Settings.Selectors.gmailDropdownText).css 'color'

    if color?
      @colorIsRed color
    else
      true

  getTextColor: =>
    @safeFind(MeetMikey.Settings.Selectors.sideBarText).css 'color'

  getInboxTextColor: =>
    $(@inboxReadTextSelector).css('color') ? @safeFind(@inboxUnreadTextSelector).css('color')

  getButtonColor: =>
    @safeFind(MeetMikey.Settings.Selectors.buttonColor).css 'background-image'

  parseRGB: (str) =>
    match = str.match /\((\d+), (\d+), (\d+)/
    colors = match[1..3].map (color) -> parseInt color, 10

    {red: colors[0], green: colors[1], blue: colors[2]}

  brightnessRGB: (colors) =>
    sum = _.reduce _.values(colors), (memo, num) -> memo + num
    sum / 3

  colorIsLight: (str) =>
    127.5 < @brightnessRGB @parseRGB(str)

  colorIsRed: (str) =>
    {red, green, blue} = @parseRGB str

    red > green and red > blue


MeetMikey.Helper.Theme = new ThemeManager()
