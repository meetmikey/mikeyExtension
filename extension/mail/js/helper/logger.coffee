class Logger
  inProductionEnv: MeetMikey.Constants.env is 'production'

  shouldLogToConsole: =>
    not MeetMikey.Helper.isRealUser()

  info: (info...) =>
    console.log(info...) if @shouldLogToConsole()

  error: (type, data) =>
    console.log('!!! error:', type, data) if @shouldLogToConsole()
    MeetMikey.Helper.callAPI
      url: 'debug'
      method: 'POST'
      data:
        type: type
        data: data


MeetMikey.Helper.Logger = new Logger()
