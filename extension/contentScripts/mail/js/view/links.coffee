template = """
  {{#unless models}}
    There doesn't seem to be any links here
  {{else}}
    <table class="inbox-table" id="mm-links-table" border="0">
      <thead class="labels">
        <th class="mm-file">Link</th>
        <th class="mm-source">Source</th>
        <th class="mm-from">From</th>
        <th class="mm-to">To</th>
        <th class="mm-sent">Sent</th>
      </thead>
      <tbody>
        {{#each models}}
          <tr class="files">
            <td class="mm-file favicon truncate">
              <div class="flex">{{title}}</div>
            </td>
            <td class="mm-source truncate">{{url}}</td>
            <td class="mm-from truncate">{{from}}</td>
            <td class="mm-to truncate">{{to}}</td>
            <td class="mm-sent truncate">{{sentDate}}</td>
          </tr>
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
    models: _.map(@collection.models, (model) -> new MeetMikey.Decorator.Link model)

  postRender: ->
