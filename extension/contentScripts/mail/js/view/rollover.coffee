class MeetMikey.View.Rollover extends MeetMikey.View.Base
  hideFlag: false

  events:
    'mouseleave': 'startHide'
    'mouseenter': 'cancelHide'

  getTemplateData: =>
    _.extend @model.decorate(), {searchQuery: @searchQuery}

  postInitialize: =>
    @cursorInfo = {}

  postRender: =>
    $(document).one 'mousemove', @startHide
    @$('.rollover-box').css left: @cursorInfo.x + 5, top: @cursorInfo.y

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

