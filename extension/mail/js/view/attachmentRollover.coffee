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
      <div class="rollover-actions">
        <div class="mm-download-tooltip rollover-resource-delete" data-toggle="tooltip" title="Hide">
          <div class="mm-hide inbox-icon "></div>
        </div>
        <div class="mm-download-tooltip" data-toggle="tooltip" title="View email">
          {{#if searchQuery}}
            <a class="rollover-message-link inbox-icon message" href="#search/{{searchQuery}}/{{threadHex}}"></a>
          {{else}}
            <a class="rollover-message-link inbox-icon message" href="#inbox/{{threadHex}}"></a>
          {{/if}}
        </div>
        <div class="mm-download-tooltip" data-toggle="tooltip" title="Star">
          <div class="inbox-icon favorite{{#if isFavorite}}On{{/if}}"></div>
        </div>
        <div class="mm-download-tooltip" data-toggle="tooltip" title="Like">
          <div id="mm-attachment-like-{{cid}}" class="inbox-icon like{{#if isLiked}}On{{/if}}"></div>
        </div>
      </div>
    </div>
  </div>
"""

class MeetMikey.View.AttachmentRollover extends MeetMikey.View.Rollover
  template: Handlebars.compile(template)