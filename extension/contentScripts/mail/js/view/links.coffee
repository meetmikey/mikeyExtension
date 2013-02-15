template = """
  {{#unless models}}
    There doesn't seem to be any links here
  {{else}}
    <table id="mm-links-table" border="0">
      <thead class="labels">
        <th class="mm-from">From</th>
        <th class="mm-to">To</th>
        <th class="mm-file">Link</th>
        <th class="mm-source">Source</th>
        <th class="mm-sent">Sent</th>
      </thead>
      <tbody>
        {{#each models}}
          {{#with attributes}}
          <tr class="files">
            <td class="mm-from truncate">{{sender.name}}</td>
            <td class="mm-to truncate">{{formatRecipients recipients}}</td>
            <td class="mm-file truncate">{{mailCleanSubject}}</td>
            <td class="mm-source truncate">{{url}}</td>
            <td class="mm-sent truncate">{{formatDate sentDate}}</td>
          </tr>
          {{/with}}
        {{/each}}
      </tbody>
    </table>
  {{/unless}}
"""

class MeetMikey.View.Links extends MeetMikey.View.Base
  template: Handlebars.compile(template)

  postInitialize: =>
    @collection = new MeetMikey.Collection.Links()
    @collection.on 'reset', @render
    @collection.fetch()

  teardown: =>
    @collection.off 'reset', @render

  getTemplateData: =>
    @collection

  postRender: ->
