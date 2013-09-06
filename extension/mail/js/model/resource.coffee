incentiveDaysAlertTemplate = """
  
  LIKES - 1,5,20,50

  <div class="mm-incentive-days-alert">
    <div class="mm-incentive-days-alert-text">
      Your first {{userActionType}}! Glad you liked it. 
      To celebrate, we just added {{numNewDays}} day{{#if numNewDaysIsNotOne}}s{{/if}} to your account for free.&nbsp;&nbsp;&nbsp;
    <div class="mm-incentive-days-alert-close">Thanks!</div>
    </div>
  </div>

  <div class="mm-incentive-days-alert">
    <div class="mm-incentive-days-alert-text">
      {{numUserActions}} {{userActionType}}{{#if numUserActionsIsNotOne}}s{{/if}} - Nice. We just added {{numNewDays}} day{{#if numNewDaysIsNotOne}}s{{/if}} to your account. Keep it up! Can you get to 20?&nbsp;&nbsp;&nbsp;
    <div class="mm-incentive-days-alert-close">Thanks!</div>
    </div>
  </div>

  <div class="mm-incentive-days-alert">
    <div class="mm-incentive-days-alert-text">
      {{numUserActions}} {{userActionType}}{{#if numUserActionsIsNotOne}}s{{/if}}! Who sends you all these sweet links? 
      We just added {{numNewDays}} day{{#if numNewDaysIsNotOne}}s{{/if}} to your account.&nbsp;&nbsp;&nbsp;
    <div class="mm-incentive-days-alert-close">Thanks!</div>
    </div>
  </div>

  <div class="mm-incentive-days-alert">
    <div class="mm-incentive-days-alert-text">
      {{numUserActions}} {{userActionType}}{{#if numUserActionsIsNotOne}}s{{/if}}! You better be tweeting some of these.
      Have a few more{{numNewDays}} day{{#if numNewDaysIsNotOne}}s{{/if}} on us.&nbsp;&nbsp;&nbsp;
    <div class="mm-incentive-days-alert-close">Thanks!</div>
    </div>
  </div>

  FAVORITES - 1,5,20,50

  <div class="mm-incentive-days-alert">
    <div class="mm-incentive-days-alert-text">
      Your first {{userActionType}}! It's a great way to bookmark stuff for later. 
      To celebrate, we just added {{numNewDays}} day{{#if numNewDaysIsNotOne}}s{{/if}} to your account for free.&nbsp;&nbsp;&nbsp;
    <div class="mm-incentive-days-alert-close">Thanks!</div>
    </div>
  </div>

  <div class="mm-incentive-days-alert">
    <div class="mm-incentive-days-alert-text">
      {{numUserActions}} {{userActionType}}{{#if numUserActionsIsNotOne}}s{{/if}}! We appreciate organized folks here and thought we would {{numNewDays}} day{{#if numNewDaysIsNotOne}}s{{/if}} to your account. Keep it up!&nbsp;&nbsp;&nbsp;
    <div class="mm-incentive-days-alert-close">Thanks!</div>
    </div>
  </div>

  <div class="mm-incentive-days-alert">
    <div class="mm-incentive-days-alert-text">
      {{numUserActions}} {{userActionType}}{{#if numUserActionsIsNotOne}}s{{/if}}! An organized inbox is the mark of a great mind. We've given you {{numNewDays}} additional day{{#if numNewDaysIsNotOne}}s{{/if}}.&nbsp;&nbsp;&nbsp;
    <div class="mm-incentive-days-alert-close">Thanks!</div>
    </div>
  </div>

  <div class="mm-incentive-days-alert">
    <div class="mm-incentive-days-alert-text">
      {{numUserActions}} {{userActionType}}{{#if numUserActionsIsNotOne}}s{{/if}}! You are definitely a power user.
      Have a few more{{numNewDays}} day{{#if numNewDaysIsNotOne}}s{{/if}} on us.&nbsp;&nbsp;&nbsp;
    <div class="mm-incentive-days-alert-close">Thanks!</div>
    </div>
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