template = """
  <div style="position: fixed;" class="rollover-box">
    <div class="rollover-main">
      <div class="rollover-title">
        <a href="{{url}}">{{filename}}</a>
      </div>
      <div class="rollover-body">
        <div class="rollover-powerpoint">
          {{#if image}}
           
            <img class="powerpoint-preview" src="{{image}}">
            
          {{/if}}
        </div>
      </div>
    </div>

    <div class="rollover-footer">
      <a href="#inbox/{{msgHex}}">View email thread</a>

      <div class="rollover-actions">
        <!-- <a href="#">Forward</a> -->
        <a href="{{url}}">Download</a>
      </div>
    </div>
  </div>
"""

class MeetMikey.View.AttachmentRollover extends MeetMikey.View.Rollover
  template: Handlebars.compile(template)
