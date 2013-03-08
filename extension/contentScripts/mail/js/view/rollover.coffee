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

  postRender: =>
    $(document).one 'mousemove', @startHide
    @$('.rollover-box').css left: @options.x + 5, top: @options.y

  startHide: =>
    @hideFlag = true
    @waitAndHide()

  hide: =>
    @_teardown() if @hideFlag

  waitAndHide: _.debounce(@prototype.hide, 400)

  cancelHide: =>
    @hideFlag = false

