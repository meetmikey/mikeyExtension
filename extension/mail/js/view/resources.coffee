class MeetMikey.View.Resources extends MeetMikey.View.Base

  eventSource: 'tab'

  isSearch: =>
    @parentView.isSearch()

  getCIDFromEvent: (event) =>
    if not event
      return
    cid = MeetMikey.Helper.getCIDFromEventWithMarker event, @cidMarkerClass, @cidMarkerClassTwo
    cid

  getModelFromCID: (cid) =>
    if not cid
      return
    model = @collection.get cid
    model

  getModelFromEvent: (event) =>
    if not event
      return
    cid = @getCIDFromEvent event
    model = @getModelFromCID cid
    model

  toggleFavoriteEvent: (event) =>
    event.preventDefault()
    model = @getModelFromEvent event
    MeetMikey.Helper.FavoriteAndLike.toggleFavorite model, @eventSource
    
  toggleLikeEvent: (event) =>
    event.preventDefault()
    model = @getModelFromEvent event
    MeetMikey.Helper.FavoriteAndLike.toggleLike model, @eventSource

  openMessage: (event) =>
    model = @getModelFromEvent event
    if not model
      return
    threadHex = MeetMikey.Helper.decimalToHex( model.get 'gmThreadId' )
    if @isSearch() and @searchQuery
      hash = "#search/#{@searchQuery}/#{threadHex}"
    else
      hash = "#inbox/#{threadHex}"

    MeetMikey.Helper.trackResourceEvent 'openMessage', model,
      currentTab: MeetMikey.Globals.tabState
      search: @isSearch()
      rollover: false

    MeetMikey.Helper.Url.setHash hash

  getFavoriteSubview: () =>
    @parentView.getFavoriteSubview()

  getNonFavoriteSubview: () =>
    @parentView.getNonFavoriteSubview()