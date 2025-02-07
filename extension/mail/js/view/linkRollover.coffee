template = """
  <div style="position: fixed;" class="rollover-box">
    <div class="rollover-main">
      <div class="rollover-title">
        <a class="rollover-resource-link" href="{{url}}">{{title}}</a>
      </div>
      <div class="rollover-body">
        <div class="rollover-image">
          {{#if image}}


              <div class="image-container">
                  <img class="aspectcorrect image-inside" src="{{image}}">
              </div>

          {{/if}}
          {{#if summary}}
            <div class="text-box">{{summary}}</div>
          {{/if}}
        </div>
      </div>
    </div>

    <div class="rollover-footer">
      {{#if searchQuery}}
        <a href="#search/{{searchQuery}}/{{threadHex}}"><div class="rollover-message-link inbox-icon message"></div></a>
      {{else}}
        <a href="#inbox/{{threadHex}}"><div class="rollover-message-link inbox-icon message"></div></a>
      {{/if}}
      <div class="rollover-actions">
        {{#if deleting}}
          <a class="rollover-resource-delete" href="#" style="display:none;">Hide link</a>
          <a class="rollover-resource-undo" href="#">Undo</a>
        {{else}}
          <a class="rollover-resource-delete" href="#">Hide link</a>
          <a class="rollover-resource-undo" href="#" style="display:none;">Undo</a>
        {{/if}}
      </div>
    </div>
  </div>
"""
class MeetMikey.View.LinkRollover extends MeetMikey.View.Rollover
  template: Handlebars.compile(template)