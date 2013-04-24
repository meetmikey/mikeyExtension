class ThemeManager
  inboxReadTextSelector: MeetMikey.Constants.Selectors.inboxReadText
  inboxUnreadTextSelector: MeetMikey.Constants.Selectors.inboxUnreadText

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
    $elem =  @safeFind MeetMikey.Constants.Selectors.tableCell
    padding = parseFloat $elem.css('padding-top')

    if padding < 4.5
      'compact'
    else if 8.5 <= padding
      'comfortable'
    else
      'cozy'

  detectTheme: =>
    if @isDefaultTheme()
      return if @borderIsHighContrast() then {blocks: 'grey-blocks'} else {}

    color = @getTextColor()
    boxColor = @getInboxTextColor()
    buttonColor = @getButtonColor()

    return {} unless color? and boxColor? and buttonColor?

    color = if @colorIsLight(color) then 'light' else 'dark'
    boxColor = if @colorIsLight(boxColor) then 'dark-blocks' else 'light-blocks'
    buttonColor = if @colorIsLight(buttonColor) then 'light-buttons' else 'dark-buttons'

    {color, boxColor, buttonColor}

  isDefaultTheme: =>
    color = @safeFind(MeetMikey.Constants.Selectors.gmailDropdownText).css 'color'

    if color?
      @colorIsRed color
    else
      true

  borderIsHighContrast: =>
    {red, green, blue} = @parseRGB @getBorderColor()

    red is 170 and green is 170 and blue is 170

  getTextColor: =>
    @safeFind(MeetMikey.Constants.Selectors.sideBarText).css 'color'

  getInboxTextColor: =>
    $(@inboxReadTextSelector).css('color') ? @safeFind(@inboxUnreadTextSelector).css('color')

  getButtonColor: =>
    @safeFind(MeetMikey.Constants.Selectors.buttonColor).css 'background-image'

  getBorderColor: =>
    @safeFind(MeetMikey.Constants.Selectors.appsSearchTable).css 'border-color'

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
