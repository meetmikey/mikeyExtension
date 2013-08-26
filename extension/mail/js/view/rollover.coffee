class MeetMikey.View.Rollover extends MeetMikey.View.Base
  hideFlag: false

  events:
    'mouseleave': 'startHide'
    'mouseenter': 'cancelHide'
    'click .rollover-resource-link': 'trackOpenResourceEvent'
    'click .rollover-message-link': 'trackOpenMessageEvent'
    'click .rollover-resource-delete' : 'deleteResource',
    'click .rollover-resource-undo' : 'unDeleteResource'

  getTemplateData: =>
    if not @model
      return
    _.extend @model.decorate(), {searchQuery: @searchQuery}

  postInitialize: =>
    @cursorInfo = {}

  postRender: =>
    $(document).one 'mousemove', @startHide
    @$('.rollover-box').css left: @cursorInfo.x + 5, top: @cursorInfo.y

  unDeleteResource: (event) =>
    console.log 'undo delete', @model

    @collection.trigger('undoDelete', @model)

    $('.rollover-resource-delete').show()
    $('.rollover-resource-undo').hide()

  deleteResource: (event) =>
    event.preventDefault()
    # remove on delay
    @collection.trigger('delete', @model)
    $('.rollover-resource-delete').hide()
    $('.rollover-resource-undo').show()

  startSpawn: (event) =>
    cid = $(event.target).closest('tr').attr('data-cid')
    @cursorInfo.cid = cid
    @cursorInfo.x = event.clientX
    @cursorInfo.y = event.clientY
    @waitAndSpawn cid

  delaySpawn: (event) =>
    cid = $(event.target).closest('tr').attr('data-cid')
    @cursorInfo.x = event.clientX
    @cursorInfo.y = event.clientY
    @waitAndSpawn cid

  spawn: (cid) =>
    return if cid isnt @cursorInfo.cid
    @model = @collection.get cid
    @render()
    @$el.show()
    @trackSpawnEvent()

  waitAndSpawn: _.debounce(@prototype.spawn, 400)

  cancelSpawn: => @cursorInfo.cid = null

  startHide: =>
    @hideFlag = true
    @waitAndHide()

  hide: =>
    @$el.hide() if @hideFlag

  waitAndHide: _.debounce(@prototype.hide, 400)

  cancelHide: =>
    @hideFlag = false

  setQuery: (query) =>
    @searchQuery = query

  trackSpawnEvent: =>
    MeetMikey.Helper.trackResourceEvent 'openRollover', @model,
      search: @searchQuery?, currentTab: MeetMikey.Globals.tabState

  trackOpenMessageEvent: =>
    MeetMikey.Helper.trackResourceEvent 'openMessage', @model,
      search: @searchQuery?, currentTab: MeetMikey.Globals.tabState, rollover: true

  trackOpenResourceEvent: =>
    MeetMikey.Helper.trackResourceEvent 'openResource', @model,
      search: @searchQuery?, currentTab: MeetMikey.Globals.tabState, rollover: true
