template = """
  <div style="position: fixed;" class="rollover-box">
    <div class="rollover-main">
      <div class="rollover-title">
        <a class="rollover-resource-link" href="{{url}}">{{filename}}</a>
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
      {{#if searchQuery}}
        <a class="rollover-message-link" href="#search/{{searchQuery}}/{{msgHex}}">View email thread</a>
      {{else}}
        <a class="rollover-message-link" href="#inbox/{{msgHex}}">View email thread</a>
      {{/if}}

      <div class="rollover-actions">
        <!-- <a href="#">Forward</a> -->
        <a class="rollover-resource-link" href="{{url}}">Download</a>
      </div>
    </div>
  </div>
"""

class MeetMikey.View.AttachmentRollover extends MeetMikey.View.Rollover
  template: Handlebars.compile(template)
