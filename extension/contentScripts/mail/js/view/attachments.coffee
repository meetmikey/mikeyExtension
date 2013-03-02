template = """
  {{#unless models}}
    <div class="mm-placeholder">Oops. It doesn't look like Mikey has any files for you.</div>
  {{else}}
    <table class="inbox-table" id="mm-attachments-table" border="0">
      <thead class="labels">
        <!-- <th class="mm-toggle-box"></th> -->
        <th class="mm-file">File</th>
        <th class="mm-from">From</th>
        <th class="mm-to">To</th>
        <th class="mm-type">Type</th>
        <th class="mm-size">Size</th>
        <th class="mm-sent">Sent</th>
      </thead>
      <tbody>
    {{#each models}}
      <tr class="files" data-attachment-url="{{getAPIUrl}}/attachmentURL/{{_id}}?userEmail={{email}}&refreshToken={{refreshToken}}">
        <!-- <td class="mm-toggle-box">
          <div class="checkbox"><div class="check"></div></div>
        </td> -->
        <td class="mm-file mm-icon truncate" style="background:url('{{iconUrl}}') no-repeat;">
          {{filename}}&nbsp;
        </td> 
        <td class="mm-from truncate">{{from}}</td>
        <td class="mm-to truncate">{{to}}</td>
        <td class="mm-type truncate">{{readableFileType}}</td>
        <td class="mm-size truncate">{{size}}</td>
        <td class="mm-sent truncate">{{sentDate}}</td>
      </tr>
    {{/each}}
    </tbody>
    </table>
  {{/unless}}
"""

class MeetMikey.View.Attachments extends MeetMikey.View.Base
  template: Handlebars.compile(template)

  events:
    'click tr': 'openAttachment'

  pollDelay: 1000*45

  preInitialize: =>

  postInitialize: =>
    @collection = new MeetMikey.Collection.Attachments()
    @collection.on 'reset add', _.debounce(@render, 50)
    if @options.fetch
      @collection.fetch success: @waitAndPoll


  attachmentRender: =>
    @render()

  postRender: =>

  teardown: =>
    @collection.off('reset', @render)

  getTemplateData: =>
    models: _.map(@collection.models, MeetMikey.Decorator.Attachment.decorate)

  openAttachment: (event) =>
    target = $(event.currentTarget)
    url = target.attr('data-attachment-url')
    window.open(url)

  waitAndPoll: =>
    setTimeout @poll, @pollDelay

  poll: =>
    console.log 'attachments are polling'
    @collection.fetch
      update: true
      remove: false
      data:
        after: @collection.first()?.get('sentDate')
      success: @waitAndPoll
      error: @waitAndPoll
