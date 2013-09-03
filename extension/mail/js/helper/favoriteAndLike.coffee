likeAlertTemplate = """
  <div class="mm-like-alert" id="mm-like-alert-{{cid}}" data-cid="{{cid}}">
      <div class="mm-like-alert-text">You just liked <strong>{{resourceName}}</strong>.</div>
    <div class="mm-undo-like" id="mm-undo-like-{{cid}}">Undo</div>
  </div>
"""

class FavoriteAndLike

  modelsCache: {}
  currentAlertCId: null

  toggleFavorite: (model, source) =>
    if not model
      return
    oldIsFavorite = model.get('isFavorite')
    newIsFavorite = true
    if oldIsFavorite
      newIsFavorite = false
    model.set 'isFavorite', newIsFavorite
    @triggerEvent 'favorite', model
    resourceType = @getResourceType model
    MeetMikey.Helper.trackResourceInteractionEvent 'resourceFavorite', resourceType, newIsFavorite, source
    model.putIsFavorite newIsFavorite, (response, status) =>
      if status != 'success'
        model.set 'isFavorite', oldIsFavorite
        @triggerEvent 'favorite', model

  updateModelFavoriteDisplay: (model, elementId) =>
    if not model
      return
    resourceType = @getResourceType model
    if not elementId
      return
    $(elementId).removeClass 'favorite'
    $(elementId).removeClass 'favoriteOn'
    if model.get 'isFavorite'
      $(elementId).addClass 'favoriteOn'
    else
      $(elementId).addClass 'favorite'

  toggleLike: (model, source) =>
    if not model
      return
    if model.get('isLiked')
      if @currentAlertCId and @currentAlertCId == model.cid
        @undoLike model
      return
    MeetMikey.Helper.Messaging.checkLikeInfoMessaging model, (shouldProceed) =>
      if not shouldProceed
        return
      model.set 'isLiked', true
      @triggerEvent 'like', model
      MeetMikey.Helper.trackResourceInteractionEvent 'resourceLike', @getResourceType(model), true, source
      @likeAfterDelay model

  showLikeAlert: (model) =>
    if @currentAlertCId
      $('#mm-undo-like-' + @currentAlertCId).remove()
      previousModel = @modelsCache[@currentAlertCId]
      if previousModel
        @doLike previousModel
      @currentAlertCId = null
    $('body').append $( @getLikeAlertHTML(model) )
    cid = model.cid
    @currentAlertCId = cid
    $('#mm-undo-like-' + cid).on 'click', @handleUndoLikeClick

  doLike: (model) =>
    if not model
      return
    likeTimeout = model.get 'likeTimeout'
    if likeTimeout
      clearTimeout likeTimeout
    @sendLike model
    @cleanModel model
    $('#mm-like-alert-' + model.cid).remove()
    delete @modelsCache[model.cid]

  handleUndoLikeClick: (event) =>
    cid = $(event.currentTarget).closest('.mm-like-alert').attr('data-cid')
    model = @modelsCache[cid]
    @undoLike model

  undoLike: (model) =>
    if not model
      return
    cid = model.cid
    $('#mm-like-alert-' + cid).remove()
    @currentAlertCId = null
    delete @modelsCache[cid]
    likeTimeout = model.get('likeTimeout')
    if likeTimeout
      clearTimeout likeTimeout
    model.set 'isLiked', false
    @triggerEvent 'like', model
    @cleanModel model

  cleanModel: (model) =>
    if not model
      return
    model.unset 'likeTimeout'

  getLikeAlertHTML: (model) =>
    resourceType = @getResourceType( model )
    resourceTypeStartsWithVowel = false
    if resourceType == 'image' or resourceType == 'attachment'
      resourceTypeStartsWithVowel = true

    resourceName = 'something'
    if resourceType == 'link'
      resourceName = model.get('title') ? model.get('url')
    else if ( resourceType == 'image' ) or ( resourceType == 'attachment' )
      resourceName = model.get 'filename'

    compiledTemplate = Handlebars.compile likeAlertTemplate
    templateData =
      resourceType: resourceType
      resourceTypeStartsWithVowel: resourceTypeStartsWithVowel
      cid: model.cid
      resourceName: resourceName
    html = compiledTemplate templateData
    html

  likeAfterDelay: (model) =>
    likeTimeout = setTimeout () =>
        @doLike model
        @currentAlertCId = null
    , MeetMikey.Constants.likeDelay
    model.set 'likeTimeout', likeTimeout
    @modelsCache[model.cid] = model
    @showLikeAlert model

  triggerEvent: (eventType, model) =>
    if not eventType or not model
      return
    if eventType isnt 'like' and eventType isnt 'favorite'
      return
    if eventType is 'like'
      value = model.get 'isLiked'
    else
      value = model.get 'isFavorite'
    resourceType = @getResourceType model
    MeetMikey.globalEvents.trigger 'favoriteOrLikeEvent', eventType, resourceType, model.id, value

  sendLike: (model) =>
    model.putIsLiked true, (response, status) =>
      if status != 'success'
        model.set 'isLiked', false
        @triggerEvent 'like', model

  updateModelLikeDisplay: (model, elementId) =>
    if not model
      return
    if not elementId
      return
    $(elementId).removeClass 'like'
    $(elementId).removeClass 'likeOn'
    if model.get 'isLiked'
      $(elementId).addClass 'likeOn'
    else
      $(elementId).addClass 'like'

  getResourceType: (model) =>
    type = 'image'
    if model
      decoratedModel = model.decorate()
      if decoratedModel.isAttachment
        type = 'attachment'
      else if decoratedModel.isLink
        type = 'link'
    type

MeetMikey.Helper.FavoriteAndLike = new FavoriteAndLike()