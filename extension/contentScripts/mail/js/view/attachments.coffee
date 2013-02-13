template = """
  {{#unless models}}
    There doesn't seem to be any files here!?!
  {{else}}
    <table id="mm-attachments-table" border="0">
      <thead class="labels">
        <th class="mm-from">From</th>
        <th class="mm-to">To</th>
        <th class="mm-file">File</th>
        <th class="mm-type">Type</th>
        <th class="mm-size">Size</th>
        <th class="mm-sent">Sent</th>
      </thead>
      <tbody>
    {{#each models}}
      {{#with attributes}}
      <tr class="files" data-attachment-url="{{getAPIUrl}}/attachmentURL/{{_id}}">
      <td class="mm-from truncate">{{sender.name}}</td>
      <td class="mm-to truncate">{{formatRecipients recipients}}</td>
      <td class="mm-file truncate">{{filename}}</td>
      <td class="mm-type truncate">pdf</td>
      <td class="mm-size truncate">{{formatBytes size}}</td>
      <td class="mm-sent truncate">{{formatDate sentDate}}</td>
      </tr>
      {{/with}}
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
    @collection

  openAttachment: (event) =>
    target = $(event.currentTarget)
    url = target.attr('data-attachment-url')
    window.open(url)


