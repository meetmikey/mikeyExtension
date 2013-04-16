template = """
  {{#unless models}}
    <div class="mm-placeholder"></div>
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
            <td class="mm-download">
              <div class="list-icon mm-download-tooltip" data-toggle="tooltip" title="View email">
                <div class="list-icon" style="background-image: url('{{../openIconUrl}}');">
                </div>
              </div>
            </td>
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

openIconUrl = chrome.extension.getURL("#{MeetMikey.Settings.imgPath}/sprite.png")

class MeetMikey.View.Links extends MeetMikey.View.Base
  template: Handlebars.compile(template)

  events:
    'click .files .mm-file': 'openLink'
    'click .files .mm-source': 'openLink'
    'click .files .mm-download': 'openMessage'
    'mouseenter .files .mm-file, .files .mm-source': 'startRollover'
    'mouseleave .files .mm-file, .files .mm-source': 'cancelRollover'
    'mousemove .files .mm-file, .files .mm-source': 'delayRollover'


  pollDelay:  MeetMikey.Settings.pollDelay

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
    $('.mm-download-tooltip').tooltip placement: 'bottom'

  teardown: =>
    @collection.off 'reset', @render
    @cachedModels = _.clone @collection.models
    @collection.reset()

  restoreFromCache: =>
    @collection.reset(@cachedModels)

  getTemplateData: =>
    models: _.invoke(@getModels(), 'decorate')
    openIconUrl: openIconUrl

  getModels: =>
    if @options.fetch
      @pagination.getPageItems()
    else
      @collection.models


  openLink: (event) =>
    cid = $(event.currentTarget).closest('.files').attr('data-cid')
    model = @collection.get cid

    MeetMikey.Helper.trackResourceEvent 'openResource', model,
      search: !@options.search, currentTab: MeetMikey.Globals.tabState, rollover: false

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

    MeetMikey.Helper.trackResourceEvent 'openMessage', model,
      currentTab: MeetMikey.Globals.tabState, search: !@options.fetch, rollover: false

    window.location = hash


  setResults: (models, query) =>
    @searchQuery = query
    @rollover.setQuery query
    @collection.reset models, sort: false

  waitAndPoll: =>
    setTimeout @poll, @pollDelay

  poll: =>
    data = if MeetMikey.globalUser.get('onboarding')
      {}
    else
      after: @collection.first()?.get('sentDate')

    console.log 'links are polling'
    @collection.fetch
      update: true
      remove: false
      data: data
      success: @waitAndPoll
      error: @waitAndPoll


