template = """
  <div style="position: fixed;" class="rollover-box">
    <div class="rollover-main">
      <div class="rollover-title">
        <a href="{{url}}">{{title}}</a>
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
      <a href="#inbox/{{msgHex}}">View email thread</a>
      <div class="rollover-actions">
        <!-- <a href="#">Forward</a> -->
        <a href="{{url}}">Download</a>
      </div>
    </div>
  </div>
"""

class MeetMikey.View.LinkRollover extends MeetMikey.View.Rollover
  template: Handlebars.compile(template)
