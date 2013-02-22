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
        <tr class="files" data-attachment-url="{{url}}">
            <td class="mm-file mm-favicon truncate" style="background:url({{faviconURL}}) no-repeat;">
              <div class="flex">
                {{title}}
                <span class="mm-file-text">{{summary}}</span>
              </div>
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

  events:
    'click tr': 'openLink'

  postInitialize: =>
    @collection = new MeetMikey.Collection.Links()
    @collection.on 'reset', @render
    @collection.fetch() if @options.fetch

  teardown: =>
    @collection.off 'reset', @render

  getTemplateData: =>
    models: _.map(@collection.models, (model) -> new MeetMikey.Decorator.Link model)

  postRender: ->

  openLink: (event) =>
    target = $(event.currentTarget)
    url = target.attr('data-attachment-url')
    window.open(url)
