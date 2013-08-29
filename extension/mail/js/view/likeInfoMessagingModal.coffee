template = """
  <div class="modal hide fade modal-like" style="display: none; ">
    <div class="modal-header">
      <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
      <h3>Alright!  It's your first Like with Mikey!</h3>
    </div>
    <div class="modal-body">
      <p>When you click Mikey's Like buttons, we shoot a quick notification to everyone in the conversation.</p>
      {{#if hasRecipients}}
        {{#if isMoreThanOneRecipient}}
          <p>In this case, the following folks will get an email saying you liked this {{resourceType}}:</p>
          {{#each recipients}}
            <b>{{name}}</b><br>
          {{/each}}
        {{else}}
          <p>In this case, <b>{{singleRecipient.name}}</b> will get an email saying you liked this {{resourceType}}.
        {{/if}}
      {{/if}}

      <p>The email will be from you and look like this:</p>
      <div class="like-email-wrapper"><div class="like-email-container" id="mm-like-info-email-template"></div></div>

    </div>
    <div style="margin-top: 20px;" class="footer-buttons">
      <a href="#" data-dismiss="modal" class="button buttons" id="mmLikeInfoMessagingProceed">Awesome. Let's do it.</a>
      <a href="#" data-dismiss="modal" class="button buttons" id="mmLikeInfoMessagingCancel">No thanks.</a>
    </div>
  </div>
"""

class MeetMikey.View.LikeInfoMessagingModal extends MeetMikey.View.BaseModal
  template: Handlebars.compile(template)

  events:
    'hidden .modal': 'thisModalHidden'
    'click #mmLikeInfoMessagingProceed': 'proceedClicked'
    'click #mmLikeInfoMessagingCancel': 'cancelClicked'

  hasReturned: false

  proceedClicked: =>
    if ! @hasReturned
      @trigger 'proceed'
      MeetMikey.Helper.Analytics.trackEvent 'acceptLikeInfoMessagingModal'
      MeetMikey.globalUser.setLikeInfoMessaging()
      @hasReturned = true

  cancelClicked: =>
    if ! @hasReturned
      MeetMikey.Helper.Analytics.trackEvent 'cancelLikeInfoMessagingModal', {source: 'cancelButton'}
      @trigger 'cancel'
      @hasReturned = true

  postRender: =>
    modelId = @resourceModel.id
    modelType = MeetMikey.Helper.FavoriteAndLike.getResourceType @resourceModel

    MeetMikey.Helper.callAPI
      url: 'likeEmailTemplate'
      data:
        modelId: modelId
        modelType: modelType
      success: (response, status) =>
        if status == 'success'
          @$('#mm-like-info-email-template').html response
    @show()

  thisModalHidden: (event) =>
    if ! @hasReturned
      MeetMikey.Helper.Analytics.trackEvent 'cancelLikeInfoMessagingModal', {source: 'nonCancelButton'}
      @trigger 'cancel'
      @hasReturned = true
    @modalHidden event

  setResourceModel: (resourceModel) =>
    @resourceModel = resourceModel

  getRecipients: () =>
    recipients = []
    if @resourceModel
      if @resourceModel.get('recipients') and @resourceModel.get('recipients').length
        recipients = _.clone @resourceModel.get('recipients')
      sender = @resourceModel.get 'sender'
      if sender
        recipients.push sender

      myEmail = MeetMikey.globalUser.get('email')
      recipients = _.reject recipients, (input) =>
        if input.email == myEmail
          return true
        false
        
      recipients = _.uniq recipients, false, (item) =>
        item.email

      if recipients.length == 0
        recipients.push
          email: myEmail
          name: MeetMikey.globalUser.getFullName()
      _.each recipients, (recipient) =>
        if not recipient.name
          recipient.name = recipient.email
    recipients

  getTemplateData: =>
    hasRecipients = false
    recipients = @getRecipients()
    singleRecipient = null
    isMoreThanOneRecipient = false
    resourceType = null
    if @resourceModel
      if recipients.length > 0
        hasRecipients = true
        singleRecipient = recipients[0]
        if recipients.length > 1
          isMoreThanOneRecipient = true
      resourceType = 'attachment'
      if @resourceModel.get 'isImage'
        resourceType = 'image'
      else if @resourceModel.get 'isLink'
        resourceType = 'link'

    object = {}
    object.hasRecipients = hasRecipients
    object.isMoreThanOneRecipient = isMoreThanOneRecipient
    object.resourceType = resourceType
    object.singleRecipient = singleRecipient
    object.recipients = recipients
    object