class BetaAccess

  checkAccess: (callback) =>
    @successCallback = callback
    if @hasAccess()
      @successCallback()
    else
      @promptForCode()

  hasAccess: =>
    submittedBetaCode = MeetMikey.Helper.LocalStore.get 'submittedBetaCode'
    if ! submittedBetaCode
      return false
    @checkBetaCode submittedBetaCode

  promptForCode: =>
    $('body').append $('<div id="mm-beta-code-modal"></div>')
    view = new MeetMikey.View.BetaCode el: '#mm-beta-code-modal'
    view.render()
    view.on 'submitted', (betaCode) =>
      if @checkBetaCode betaCode
        view.hide()
        @successCallback()
      else
        view.wrongCode()

  checkBetaCode: (betaCodeInput) =>
    if ! betaCodeInput
      return false
    MeetMikey.Helper.LocalStore.set 'submittedBetaCode', betaCodeInput
    betaCodeHash = MeetMikey.Helper.getBetaCodeHash betaCodeInput
    betaCodeHash == MeetMikey.Settings.betaCodeHash

MeetMikey.Helper.BetaAccess = new BetaAccess()