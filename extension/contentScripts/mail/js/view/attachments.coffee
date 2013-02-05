template = """
  {{#unless models}}
    There doesn't seem to be any files here!?!
  {{else}}
    <table class="F cf zt">
      <thead>
        <th>From</th>
        <th>Sent to</th>
        <th>File</th>
        <th>Size</th>
        <th>Date</th>
      </thead>
      <tbody>
    {{#each models}}
      {{#with attributes}}
      <tr class="zf zA" data-attachment-url="{{getAPIUrl}}/attachmentURL/{{_id}}">
      <td>{{sender.name}}</td>
      <td>{{formatRecipients recipients}}</td>
      <td>{{filename}}</td>
      <td>{{formatBytes size}}</td>
      <td>{{formatDate sentDate}}</td>
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

  postRender: =>
    console.log @collection.models
    console.log 'rendered'

  openAttachment: (event) =>
    target = $(event.currentTarget)
    url = target.attr('data-attachment-url')
    window.open(url)


