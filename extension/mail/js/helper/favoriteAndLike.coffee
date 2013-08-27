likeAlertTemplate = """
  <div class="mm-like-alert" id="mm-like-alert-{{cid}}" data-cid="{{cid}}">
    You just 'liked' a{{#if resourceTypeStartsWithVowel}}n{{/if}} {{resourceType}}.
    <div class="mm-undo-like" id="mm-undo-like-{{cid}}">Undo.</div>
  </div>
"""

class FavoriteAndLike

  modelsCache: {}

  toggleFavorite: (model, elementId, source, callback) =>
    if not model
      return
    oldIsFavorite = model.get('isFavorite')
    newIsFavorite = true
    if oldIsFavorite
      newIsFavorite = false
    model.set 'isFavorite', newIsFavorite
    @updateModelFavoriteDisplay model, elementId
    MeetMikey.Helper.trackResourceInteractionEvent 'resourceFavorite', @getResourceType(model), newIsFavorite, source
    model.putIsFavorite newIsFavorite, (response, status) =>
      if status != 'success'
        model.set 'isFavorite', oldIsFavorite
        @updateModelFavoriteDisplay model, elementId
        if callback
          callback 'fail'
      else
        MeetMikey.globalEvents.trigger 'favoriteOrLikeAction'
        if callback
          callback 'success'

  updateModelFavoriteDisplay: (model, elementId) =>
    if ( not model ) or ( not elementId )
      return
    $(elementId).removeClass 'favorite'
    $(elementId).removeClass 'favoriteOn'
    if model.get 'isFavorite'
      $(elementId).addClass 'favoriteOn'
    else
      $(elementId).addClass 'favorite'

  toggleLike: (model, elementId, source, callback) =>
    if not model
      return
    if model.get('isLiked')
      return
    MeetMikey.Helper.Messaging.checkLikeInfoMessaging model, (shouldProceed) =>
      if not shouldProceed
        return
      model.set 'isLiked', true
      model.set 'elementId', elementId
      @updateModelLikeDisplay model, elementId
      MeetMikey.Helper.trackResourceInteractionEvent 'resourceLike', @getResourceType(model), true, source
      @likeAfterDelay model, elementId, callback

  showLikeAlert: (model) =>
    $('body').append $( @getLikeAlertHTML(model) )
    cid = model.cid
    $('#mm-undo-like-' + cid).on 'click', @handleUndoLikeClick

  handleUndoLikeClick: (event) =>
    cid = $(event.currentTarget).closest('.mm-like-alert').attr('data-cid')
    model = @modelsCache[cid]
    elementId = model.get 'elementId'
    @cancelLike model, elementId
    $('#mm-like-alert-' + cid).remove()
    model.unset 'elementId'
    delete @modelsCache[cid]

  getLikeAlertHTML: (model) =>
    resourceType = @getResourceType( model )
    resourceTypeStartsWithVowel = false
    if resourceType == 'image' or resourceType == 'attachment'
      resourceTypeStartsWithVowel = true

    compiledTemplate = Handlebars.compile likeAlertTemplate
    templateData =
      resourceType: resourceType
      resourceTypeStartsWithVowel: resourceTypeStartsWithVowel
      cid: model.cid
    html = compiledTemplate templateData
    html

  likeAfterDelay: (model, elementId, callback) =>
    likeTimeout = setTimeout () =>
        @sendLike model, elementId, callback
        model.unset 'likeTimeout'
        model.unset 'elementId'
        cid = model.cid
        $('#mm-like-alert-' + cid).remove()
        delete @modelsCache[model.cid]
    , MeetMikey.Constants.likeDelay
    model.set 'likeTimeout', likeTimeout
    @modelsCache[model.cid] = model
    @showLikeAlert model

  cancelLike: (model, elementId) =>
    if not model.get('likeTimeout')
      return
    clearTimeout model.get('likeTimeout')
    model.set 'isLiked', false
    @updateModelLikeDisplay model, elementId

  sendLike: (model, elementId, callback) =>
    model.putIsLiked true, (response, status) =>
      if status != 'success'
        model.set 'isLiked', false
        @updateModelLikeDisplay model, elementId
        if callback
          callback 'fail'
      else
        MeetMikey.globalEvents.trigger 'favoriteOrLikeAction'
        if callback
          callback 'success'

  updateModelLikeDisplay: (model, elementId) =>
    if ( not model ) or ( not elementId )
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