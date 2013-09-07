incentiveDaysAlertTemplate = """
  <div class="mm-incentive-days-alert">
    <div class="mm-incentive-days-alert-text">

      {{#if isLike}}

        <!-- like -->
      
        {{#if messageOne}}
          Your first {{userActionType}}! Glad you liked it. 
          To celebrate, we just added {{numNewDays}} day{{#if numNewDaysIsNotOne}}s{{/if}} to your account for free.&nbsp;
        {{else}}
          {{#if messageTwo}}
            {{numUserActions}} {{userActionType}}{{#if numUserActionsIsNotOne}}s{{/if}} - Nice. We just added {{numNewDays}} day{{#if numNewDaysIsNotOne}}s{{/if}} to your account. Keep it up! Can you get to 20?&nbsp;
          {{else}}
            {{#if messageThree}}
              {{numUserActions}} {{userActionType}}{{#if numUserActionsIsNotOne}}s{{/if}}! Who sends you all this great stuff?
              We just added {{numNewDays}} day{{#if numNewDaysIsNotOne}}s{{/if}} to your account.&nbsp;
            {{else}}
              {{#if messageFour}}
                {{numUserActions}} {{userActionType}}{{#if numUserActionsIsNotOne}}s{{/if}}! You better be tweeting some of these.
                Have {{numNewDays}} day{{#if numNewDaysIsNotOne}}s{{/if}} on us.&nbsp;
              {{/if}}
            {{/if}}
          {{/if}}
        {{/if}}

      {{else}}

        <!-- favorite -->

        {{#if messageOne}}
          Your first {{userActionType}}! It's a great way to bookmark stuff for later. 
          To celebrate, we just added {{numNewDays}} day{{#if numNewDaysIsNotOne}}s{{/if}} to your account for free.&nbsp;
        {{else}}
          {{#if messageTwo}}
            {{numUserActions}} {{userActionType}}{{#if numUserActionsIsNotOne}}s{{/if}}! We appreciate organized folks and thought we would add {{numNewDays}} day{{#if numNewDaysIsNotOne}}s{{/if}} to your account. Keep it up!&nbsp;
          {{else}}
            {{#if messageThree}}
              {{numUserActions}} {{userActionType}}{{#if numUserActionsIsNotOne}}s{{/if}}! An organized inbox is the mark of a great mind. We've given you {{numNewDays}} additional day{{#if numNewDaysIsNotOne}}s{{/if}}.&nbsp;
            {{else}}
              {{#if messageFour}}
                {{numUserActions}} {{userActionType}}{{#if numUserActionsIsNotOne}}s{{/if}}! You are definitely a power user.
                Have {{numNewDays}} day{{#if numNewDaysIsNotOne}}s{{/if}} on us.&nbsp;
              {{/if}}
            {{/if}}
          {{/if}}
        {{/if}}

      {{/if}}

      <div class="mm-incentive-days-alert-close">Got it.</div>
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
    isFavorite = true
    isLike = false
    if userActionType is 'like'
      isFavorite = false
      isLike = true

    messageOne = true
    if numUserActions > MeetMikey.Constants.userActionThresholdOne
      messageOne = false
      messageTwo = true
    if numUserActions > MeetMikey.Constants.userActionThresholdTwo
      messageTwo = false
      messageThree = true
    if numUserActions > MeetMikey.Constants.userActionThresholdThree
      messageThree = false
      messageFour = true
    templateData =
      userActionType: userActionType
      numUserActions: numUserActions
      numUserActionsIsNotOne: numUserActionsIsNotOne
      numNewDays: numNewDays
      numNewDaysIsNotOne: numNewDaysIsNotOne
      isFavorite: isFavorite
      isLike: isLike
      messageOne: messageOne
      messageTwo: messageTwo
      messageThree: messageThree
      messageFour: messageFour
    html = compiledTemplate templateData
    html