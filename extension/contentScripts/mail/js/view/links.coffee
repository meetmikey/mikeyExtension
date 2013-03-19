template = """
  {{#unless models}}
    <div class="mm-placeholder">Oops. It doesn't look like Mikey has any links for you.</div>
  {{else}}
    <table class="inbox-table" id="mm-links-table" border="0">
      <thead class="labels">
        <th class="mm-file mm-link">Link</th>
        <th class="mm-source">Source</th>
        <th class="mm-from">From</th>
        <th class="mm-to">To</th>
        <th class="mm-sent">Sent</th>
      </thead>
      <tbody>
        {{#each models}}
        <tr class="files" data-cid="{{cid}}">
            <td class="mm-file mm-favicon truncate" style="background:url({{faviconURL}}) no-repeat;">
              <div class="flex">
                {{title}}
                <span class="mm-file-text">{{summary}}</span>
              </div>
            </td>
            <td class="mm-source truncate">{{displayUrl}}</td>
            <td class="mm-from truncate">{{from}}</td>
            <td class="mm-to truncate">{{to}}</td>
            <td class="mm-sent truncate">{{sentDate}}</td>
          </tr>
        {{/each}}
      </tbody>
    </table>
    <div class="rollover-container"></div>
  {{/unless}}
"""

class MeetMikey.View.Links extends MeetMikey.View.Base
  template: Handlebars.compile(template)

  events:
    'click .files': 'openLink'
    'mouseenter .files': 'startRollover'
    'mouseleave .files': 'cancelRollover'
    'mousemove .files': 'delayRollover'

  pollDelay: 1000*45

  postInitialize: =>
    @collection = new MeetMikey.Collection.Links()
    @rollover = new MeetMikey.View.LinkRollover collection: @collection, search: !@options.fetch
    @collection.on 'reset add', _.debounce(@render, 50)
    if @options.fetch
      @collection.fetch success: @waitAndPoll

  postRender: =>
    @rollover.setElement @$('.rollover-container')

  teardown: =>
    @collection.off 'reset', @render

  getTemplateData: =>
    models: _.invoke(@collection.models, 'decorate')

  openLink: (event) =>
    cid = $(event.currentTarget).attr('data-cid')
    model = @collection.get cid
    window.open model.get('url')

  startRollover: (event) => @rollover.startSpawn event

  delayRollover: (event) => @rollover.delaySpawn event

  cancelRollover: => @rollover.cancelSpawn()

  setResults: (models, query) =>
    @searchQuery = query
    @rollover.setQuery query
    @collection.reset models, sort: false

  waitAndPoll: =>
    setTimeout @poll, @pollDelay

  poll: =>
    console.log 'links are polling'
    @collection.fetch
      update: true
      remove: false
      data:
        after: @collection.first()?.get('sentDate')
      success: @waitAndPoll
      error: @waitAndPoll
