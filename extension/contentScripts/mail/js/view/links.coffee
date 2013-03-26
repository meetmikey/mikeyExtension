template = """
  {{#unless models}}
    <div class="mm-placeholder">Oops. It doesn't look like Mikey has any links for you.</div>
  {{else}}
    <div class="pagination-container"></div>
    <table class="inbox-table" id="mm-links-table" border="0">
      <thead class="labels">
        <th class="mm-download">Link</th>
        <th class="mm-file mm-link"></th>
        <th class="mm-source">Source</th>
        <th class="mm-from">From</th>
        <th class="mm-to">To</th>
        <th class="mm-sent">Sent</th>
      </thead>
      <tbody>
        {{#each models}}
        <tr class="files" data-cid="{{cid}}">
            <td class="mm-download" style="background-image: url('{{../openIconUrl}}');">&nbsp;</td>
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

openIconUrl = chrome.extension.getURL("#{MeetMikey.Settings.imgPath}/open-link.png")

class MeetMikey.View.Links extends MeetMikey.View.Base
  template: Handlebars.compile(template)

  events:
    'click .files .mm-file': 'openMessage'
    'click .files .mm-download': 'openLink'
    'mouseenter .files': 'startRollover'
    'mouseleave .files': 'cancelRollover'
    'mousemove .files': 'delayRollover'

  pollDelay: 1000*45

  postInitialize: =>
    @collection = new MeetMikey.Collection.Links()
    @rollover = new MeetMikey.View.LinkRollover collection: @collection, search: !@options.fetch
    @pagination = new MeetMikey.Model.PaginationState items: @collection

    @collection.on 'reset add', _.debounce(@render, 50)
    @pagination.on 'change:page', @render

    if @options.fetch
      @collection.fetch success: @waitAndPoll

  postRender: =>
    @rollover.setElement @$('.rollover-container')

  teardown: =>
    @collection.off 'reset', @render

  getTemplateData: =>
    models: _.invoke(@getModels(), 'decorate')
    openIconUrl: openIconUrl

  getModels: =>
    if @options.fetch
      @pagination.getPageItems()
    else
      @collection.models


  openLink: (event) =>
    cid = $(event.currentTarget).attr('data-cid')
    model = @collection.get cid

    MeetMikey.Heper.Mixpanel.trackEvent 'openLink',
      modelId: model.id, search: !@options.fetch

    window.open model.get('url')

  startRollover: (event) => @rollover.startSpawn event

  delayRollover: (event) => @rollover.delaySpawn event

  cancelRollover: => @rollover.cancelSpawn()

  openMessage: (event) =>
    cid = $(event.currentTarget).closest('.files').attr('data-cid')
    model = @collection.get(cid)
    msgHex = model.get 'gmMsgHex'
    if @options.fetch
      hash = "#inbox/#{msgHex}"
    else
      hash = "#search/#{@searchQuery}/#{msgHex}"

    MeetMikey.Helper.Mixpanel.trackEvent 'openMessage',
      currentTab: MeetMikey.Globals.tabState, modelId: model.id, search: !@options.fetch

    window.location = hash


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


