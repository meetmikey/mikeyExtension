incentiveDaysAlertTemplate = """
  <div class="mm-incentive-days-alert">
    <div class="mm-incentive-days-alert-text">
      Thanks for using Mikey's '{{userActionType}}' feature!
      Since you've done it {{numUserActions}} time{{#if numUserActionsIsNotOne}}s{{/if}}, we just added {{numNewDays}} day{{#if numNewDaysIsNotOne}}s{{/if}} to your account for free.
    </div>
    <div class="mm-incentive-days-alert-close">&nbsp;&nbsp;&nbsp;Thanks!</div>
  </div>
"""

class MeetMikey.Model.Resource extends MeetMikey.Model.Base
  idAttribute: "_id"
  decorator: MeetMikey.Decorator.Attachment
  alertTimeout: 8000

  putIsFavorite: (isFavorite, callback) =>
    @putResource 'favorite', isFavorite, callback

  putIsLiked: (isLiked, callback) =>
    @putResource 'like', isLiked, callback

  putResource: (userActionType, value, callback) =>
    data = {}
    if userActionType is 'favorite'
      data = { 'isFavorite': value }
    else if userActionType is 'like'
      data = { 'isLiked': value }
    MeetMikey.Helper.callAPI
      type: 'PUT'
      url: @apiURLRoot + '/' + @get('_id')
      complete: callback
      data: data
      success: (response) =>
        @handlePutResponse response, userActionType

  delete: =>
    MeetMikey.Helper.callAPI
      type: 'DELETE'
      url: @apiURLRoot + '/' + @get('_id')

  handlePutResponse: (response, userActionType) =>
    if not response
      return
    hitNewThreshold = response.hitNewThreshold
    numUserActions = response.numUserActions
    numNewDays = response.numNewDays

    #TEMP!!!!
    hitNewThreshold = true
    numUserActions = 5
    numNewDays = 5

    if not hitNewThreshold
      return
    MeetMikey.globalUser.refreshFromServer()
    @showIncentiveDaysAlert userActionType, numUserActions, numNewDays

  showIncentiveDaysAlert: (userActionType, numUserActions, numNewDays) =>
    selector = '.mm-incentive-days-alert'
    closeSelector = '.mm-incentive-days-alert-close'
    $(selector).remove()
    $('body').append $( @getIncentiveDaysAlertHTML(userActionType, numUserActions, numNewDays) )
    $(closeSelector).on 'click', () =>
      $(selector).remove()
    if MeetMikey.globalIncentiveDaysAlertTimeout
      clearTimeout MeetMikey.globalIncentiveDaysAlertTimeout
    MeetMikey.globalIncentiveDaysAlertTimeout = setTimeout () =>
      $(selector).remove()
      MeetMikey.globalIncentiveDaysAlertTimeout = null
    , @alertTimeout

  getIncentiveDaysAlertHTML: (userActionType, numUserActions, numNewDays) =>
    compiledTemplate = Handlebars.compile incentiveDaysAlertTemplate
    numUserActionsIsNotOne = true
    if numUserActions is 1
      numUserActionsIsNotOne = false
    numNewDaysIsNotOne = true
    if numNewDays is 1
      numNewDaysIsNotOne = false
    templateData =
      userActionType: userActionType
      numUserActions: numUserActions
      numUserActionsIsNotOne: numUserActionsIsNotOne
      numNewDays: numNewDays
      numNewDaysIsNotOne: numNewDaysIsNotOne
    html = compiledTemplate templateData
    html