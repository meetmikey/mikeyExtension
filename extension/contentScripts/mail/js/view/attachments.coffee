template = """
  {{#unless models}}
    There doesn't seem to be any files here!?!
  {{else}}
    <table class="inbox-table" id="mm-attachments-table" border="0">
      <thead class="labels">
        <th class="mm-toggle-box"></th>
        <th class="mm-file">File</th>
        <th class="mm-from">From</th>
        <th class="mm-to">To</th>
        <th class="mm-type">Type</th>
        <th class="mm-size">Size</th>
        <th class="mm-sent">Sent</th>
      </thead>
      <tbody>
    {{#each models}}
      <tr class="files" data-attachment-url="{{getAPIUrl}}/attachmentURL/{{_id}}?userEmail={{email}}">
        <td class="mm-toggle-box">
          <div class="checkbox"><div class="check"></div></div>
        </td>
        <td class="mm-file truncate">{{filename}}</td>
        <td class="mm-from truncate">{{from}}</td>
        <td class="mm-to truncate">{{to}}</td>
        <td class="mm-type truncate">pdf</td>
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

  postInitialize: =>
    @collection = new MeetMikey.Collection.Attachments()
    @collection.on('reset', @render)
    @collection.fetch()

  teardown: =>
    @collection.off('reset', @render)

  getTemplateData: =>
    models: _.map(@collection.models, (model) -> new MeetMikey.Decorator.Attachment model)

  openAttachment: (event) =>
    target = $(event.currentTarget)
    url = target.attr('data-attachment-url')
    window.open(url)


