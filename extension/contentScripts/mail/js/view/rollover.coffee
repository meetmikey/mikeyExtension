template = """
  <div style="position: fixed;" class="rollover-box">
    <div class="rollover-main">
      <div class="rollover-title">
        <a href="{{url}}">{{filename}}</a>
      </div>
      <div class="rollover-body rollover-powerpoint">
        {{#if image}}
          <img class="powerpoint-preview" src="{{image}}">
        {{/if}}
      </div>
    </div>

    <div class="rollover-footer">
      <a href="#inbox/{{msgHex}}">View email thread</a>
      <div class="rollover-actions">
        <a href="#">Forward</a>
        <a href="{{url}}">Download</a>
      </div>
    </div>
  </div>
"""

class MeetMikey.View.Rollover extends MeetMikey.View.Base
  template: Handlebars.compile(template)

  hideFlag: false

  events:
    'mouseleave': 'startHide'
    'mouseenter': 'cancelHide'

  getTemplateData: =>
    @model.decorate()

  postInitialize: =>
    @cursorInfo = {}

  postRender: =>
    console.log 'rendered', @$el
    $(document).one 'mousemove', @startHide
    @$('.rollover-box').css left: @cursorInfo.x + 5, top: @cursorInfo.y

  startSpawn: (event) =>
    cid = $(event.target).parent('tr').attr('data-cid')
    @cursorInfo.cid = cid
    @cursorInfo.x = event.pageX
    @cursorInfo.y = event.pageY
    @waitAndSpawn cid

  delaySpawn: (event) =>
    cid = $(event.target).parent('tr').attr('data-cid')
    @cursorInfo.x = event.pageX
    @cursorInfo.y = event.pageY
    @waitAndSpawn cid

  spawn: (cid) =>
    return if cid isnt @cursorInfo.cid
    @model = @collection.get cid
    # @$el.append '<div class="rollover"></div>'
    @render()
    @$el.show()

  waitAndSpawn: _.debounce(@prototype.spawn, 400)

  cancelSpawn: => @cursorInfo.cid = null

  startHide: =>
    console.log 'start'
    @hideFlag = true
    @waitAndHide()

  hide: =>
    console.log 'hide'
    @$el.hide() if @hideFlag

  waitAndHide: _.debounce(@prototype.hide, 400)

  cancelHide: =>
    console.log 'cancel'
    @hideFlag = false

