class FavoriteAndLike

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

  toggleLike: (model, elementId, source) =>
    if not model
      return
    if model.get('isLiked')
      return
    MeetMikey.Helper.Messaging.checkLikeInfoMessaging model, (shouldProceed) =>
      if not shouldProceed
        return
    model.set 'isLiked', true
    @updateModelLikeDisplay model, elementId
    MeetMikey.Helper.trackResourceInteractionEvent 'resourceLike', @getResourceType(model), true, source
    model.putIsLiked true, (response, status) =>
      if status != 'success'
        model.set 'isLiked', false
        @updateModelLikeDisplay model
      else
        MeetMikey.globalEvents.trigger 'favoriteOrLikeAction'

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