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
        <a class="rollover-message-link" href="#search/{{searchQuery}}/{{msgHex}}">View email thread</a>
      {{else}}
        <a class="rollover-message-link" href="#inbox/{{msgHex}}">View email thread</a>
      {{/if}}
      <div class="rollover-actions">
        <!-- <a href="#">Forward</a> -->
        <!-- <a class="rollover-resource-link" href="{{url}}">Download</a> -->
      </div>
    </div>
  </div>
"""

class MeetMikey.View.LinkRollover extends MeetMikey.View.Rollover
  template: Handlebars.compile(template)