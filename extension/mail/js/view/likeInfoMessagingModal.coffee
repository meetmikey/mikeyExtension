template = """
  <div class="modal hide fade modal-wide" style="display: none; ">
    <div class="modal-header">
      <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
      <h3>Alright!  It's your first 'like' with Mikey!</h3>
    </div>
    <div class="modal-body">
      <p>When you click Mikey's like buttons, the people in that conversation see that you liked that attachment, link, or image.</p>
      {{#if hasRecipients}}
        {{#if isMoreThanOneRecipient}}
          <p>In this case, the following folks will get an email saying you liked this {{resourceType}}.
          {{#each recipients}}
            <br/>
            <b>{{name}}</b>
          {{/each}}
        {{else}}
          <p>In this case, <b>{{singleRecipient.name}}</b> will get an email saying you liked this {{resourceType}}.
        {{/if}}
      {{/if}}

      <p>The email will be from you and look like this:</p>
      <div id="mm-like-info-email-template"></div>

      <p>Ready? Click ok below to send your like, and we won't show you this message again.</p>
    </div>
    <div class="footer-buttons">
      <a href="#" data-dismiss="modal" class="button buttons" id="mmLikeInfoMessagingProceed">ok</a>
      <a href="#" data-dismiss="modal" class="button buttons" id="mmLikeInfoMessagingCancel">cancel</a>
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
      MeetMikey.globalUser.setLikeInfoMessaging()
      @hasReturned = true

  cancelClicked: =>
    if ! @hasReturned
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