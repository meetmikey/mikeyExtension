template = """
  {{#unless models}}
    <div class="mm-placeholder"></div>
  {{else}}
    <div class="pagination-container"></div>
    <table class="inbox-table" id="mm-attachments-table" border="0">
      <thead class="labels">
        <!-- <th class="mm-toggle-box"></th> -->

        <th class="mm-download">File</th>
        <th class="mm-icon">&nbsp;</th>
        <th class="mm-file">&nbsp;</th>
        <th class="mm-from">From</th>
        <th class="mm-to">To</th>
        <th class="mm-type">Type</th>
        <th class="mm-size">Size</th>
        <th class="mm-sent">Sent</th>
      </thead>
      <tbody>
    {{#each models}}
      <tr class="files" data-cid="{{cid}}">
        <!-- <td class="mm-toggle-box">
          <div class="checkbox"><div class="check"></div></div>
        </td> -->

         <td class="mm-download">
              <div class="list-icon mm-download-tooltip" data-toggle="tooltip" title="View email">
                <div class="list-icon" style="background-image: url('{{../downloadUrl}}');">
                </div>
              </div>
          </td>
        <td class="mm-icon" style="background:url('{{iconUrl}}') no-repeat;">&nbsp;</td>
        <td class="mm-file truncate">{{filename}}&nbsp;</td>
        <td class="mm-from truncate">{{from}}</td>
        <td class="mm-to truncate">{{to}}</td>
        <td class="mm-type truncate">{{type}}</td>
        <td class="mm-size truncate">{{size}}</td>
        <td class="mm-sent truncate">{{sentDate}}</td>
      </tr>
    {{/each}}
    </tbody>
    </table>
    <div class="rollover-container"></div>
  {{/unless}}
"""
downloadUrl = chrome.extension.getURL("#{MeetMikey.Settings.imgPath}/sprite.png")


class MeetMikey.View.Attachments extends MeetMikey.View.Base
  template: Handlebars.compile(template)

  events:
    'click .files .mm-file': 'openAttachment'
    'click .files .mm-download': 'openMessage'
    'mouseenter .files .mm-file, .files .mm-icon': 'startRollover'
    'mouseleave .files .mm-file, .files .mm-icon': 'cancelRollover'
    'mousemove .files .mm-file, .files .mm-icon': 'delayRollover'

  pollDelay: MeetMikey.Settings.pollDelay

  preInitialize: =>

  postInitialize: =>
    @collection = new MeetMikey.Collection.Attachments()
    @rollover = new MeetMikey.View.AttachmentRollover collection: @collection, search: !@options.fetch
    @pagination = new MeetMikey.Model.PaginationState items: @collection


    @collection.on 'reset add', _.debounce(@render, 50)

    if @options.fetch
      @pagination.on 'change:page', @render
      @collection.fetch success: @waitAndPoll

  postRender: =>
    @rollover.setElement @$('.rollover-container')
    $('.mm-download-tooltip').tooltip placement: 'bottom'

  teardown: =>
    @collection.off('reset', @render)

  getTemplateData: =>
    models: _.invoke(@getModels(), 'decorate')
    downloadUrl: downloadUrl

  getModels: =>
    if @options.fetch
      @pagination.getPageItems()
    else
      @collection.models

  openAttachment: (event) =>
    cid = $(event.currentTarget).closest('.files').attr('data-cid')
    model = @collection.get(cid)
    url = model.getUrl()

    MeetMikey.Helper.trackResourceEvent 'openResource', model,
      search: !@options.search, currentTab: MeetMikey.Globals.tabState, rollover: false

    window.open(url)

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
    data = if MeetMikey.globalUser.get('onboarding')
      {}
    else
      after: @collection.first()?.get('sentDate')

    console.log 'attachments are polling'
    @collection.fetch
      update: true
      remove: false
      data: data
      success: @waitAndPoll
      error: @waitAndPoll
