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
        <a class="rollover-message-link" href="#search/{{searchQuery}}/{{threadHex}}">View email thread</a>
      {{else}}
        <a class="rollover-message-link" href="#inbox/{{threadHex}}">View email thread</a>
      {{/if}}

      <div class="rollover-actions">
        <!-- <a href="#">Forward</a> -->
        <!-- <a class="rollover-resource-link" href="{{url}}">Download</a> -->
        {{#if deleting}}
          <a class="rollover-resource-delete" href="#" style="display:none;">Hide</a>
          <a class="rollover-resource-undo" href="#">Undo</a>
        {{else}}
          <a class="rollover-resource-delete" href="#">Hide</a>
          <a class="rollover-resource-undo" href="#" style="display:none;">Undo</a>
        {{/if}}
      </div>
    </div>
  </div>
"""

class MeetMikey.View.AttachmentRollover extends MeetMikey.View.Rollover
  template: Handlebars.compile(template)