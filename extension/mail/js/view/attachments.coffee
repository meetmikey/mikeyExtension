spriteUrl = chrome.extension.getURL("#{MeetMikey.Constants.imgPath}/sprite.png")
template = """
  {{#unless models}}
    <div class="mm-placeholder"></div>
  {{else}}
    <div class="pagination-container"></div>
    <table class="inbox-table search-results" id="mm-attachments-table" border="0">
      <thead class="labels">
        <!-- <th class="mm-toggle-box"></th> -->


        <th class="mm-download" colspan="3" data-mm-field="filename">File<div style="background-image: url('#{spriteUrl}');" class="sort-carat">&nbsp;</div></th>
        <th class="mm-file">&nbsp;</th>
        <th class="mm-from" data-mm-field="sender">From<div style="background-image: url('#{spriteUrl}');" class="sort-carat">&nbsp;</div></th>
        <th class="mm-to" data-mm-field="recipients">To<div style="background-image: url('#{spriteUrl}');" class="sort-carat">&nbsp;</div></th>
        <th class="mm-type" data-mm-field="docType">Type<div style="background-image: url('#{spriteUrl}');" class="sort-carat">&nbsp;</div></th>
        <th class="mm-size" data-mm-field="fileSize">Size<div style="background-image: url('#{spriteUrl}');" class="sort-carat">&nbsp;</div></th>
        <th class="mm-sent" data-mm-field="sentDate">Sent<div style="background-image: url('#{spriteUrl}');" class="sort-carat">&nbsp;</div></th>

      </thead>
      <tbody>
    {{#each models}}
        <tr class="files" data-cid="{{cid}}">
        {{#if deleting}}
          <td class="mm-hide" style="opacity:0.1">
            <div class="mm-download-tooltip" data-toggle="tooltip" title="Hide this file">
              <a href="#"><div class="close-x">x</div></a>
            </div>
          </td>
          <td class="mm-download" style="opacity:0.1">
              <div class="list-icon mm-download-tooltip" data-toggle="tooltip" title="View email">
                <div class="list-icon" style="background-image: url('#{spriteUrl}');">
                </div>
              </div>
          </td>
          <td class="mm-icon" style="background:url('{{iconUrl}}') no-repeat; opacity:0.1">&nbsp;</td>
          <td class="mm-undo">{{filename}} won't be shown anymore! <strong>Click here to undo.</strong> </td>
          <td class="mm-file truncate" style="display:none;">{{filename}}&nbsp;</td>
          <td class="mm-from truncate" style="opacity:0.1">{{from}}</td>
          <td class="mm-to truncate" style="opacity:0.1">{{to}}</td>
          <td class="mm-type truncate" style="opacity:0.1">{{type}}</td>
          <td class="mm-size truncate" style="opacity:0.1">{{size}}</td>
          <td class="mm-sent truncate" style="opacity:0.1">{{sentDate}}</td>
        {{else}}
          <td class="mm-hide">
            <div class="mm-download-tooltip" data-toggle="tooltip" title="Hide this file">
              <a href="#"><div class="close-x">x</div></a>
            </div>
          </td>

          <td class="mm-download">
              <div class="list-icon mm-download-tooltip" data-toggle="tooltip" title="View email">
                <div class="list-icon" style="background-image: url('#{spriteUrl}');">
                </div>
              </div>
          </td>
          
          <td class="mm-icon" style="background:url('{{iconUrl}}') no-repeat;">&nbsp;</td>
          <td class="mm-undo" style="display:none;">{{filename}} won't be shown anymore! Click to UNDO </td>
          <td class="mm-file truncate">{{filename}}&nbsp;</td>
          <td class="mm-from truncate">{{from}}</td>
          <td class="mm-to truncate">{{to}}</td>
          <td class="mm-type truncate">{{type}}</td>
          <td class="mm-size truncate">{{size}}</td>
          <td class="mm-sent truncate">{{sentDate}}</td>
        {{/if}}
        </tr>
    {{/each}}
    </tbody>
    </table>
    <div class="rollover-container"></div>
  {{/unless}}
"""


class MeetMikey.View.Attachments extends MeetMikey.View.Base
  template: Handlebars.compile(template)

  events:
    'click .files .mm-file': 'openAttachment'
    'click .files .mm-download': 'openMessage'
    'click .close-x' : 'markDeletingEvent'
    'click .files .mm-undo' : 'unMarkDeletingEvent'
    'click th': 'sortByColumn'
    'mouseenter .files .mm-file, .files .mm-icon': 'startRollover'
    'mouseleave .files .mm-file, .files .mm-icon': 'cancelRollover'
    'mousemove .files .mm-file, .files .mm-icon': 'delayRollover'

  pollDelay: MeetMikey.Constants.pollDelay

  preInitialize: =>

  postInitialize: =>
    @collection = new MeetMikey.Collection.Attachments()
    @rollover = new MeetMikey.View.AttachmentRollover collection: @collection, search: !@options.fetch
    @pagination = new MeetMikey.Model.PaginationState items: @collection

    @collection.on 'reset add', _.debounce(@render, MeetMikey.Constants.paginationSize)
    @pagination.on 'change:page', @render
    @collection.on 'sort', @render
    @collection.on 'remove', @render
    @collection.on 'delete', @markDeleting
    @collection.on 'undoDelete', @unMarkDeleting

  postRender: =>
    @rollover.setElement @$('.rollover-container')
    $('.mm-download-tooltip').tooltip placement: 'bottom'
    @setActiveColumn()

  teardown: =>
    @clearTimeout()
    @collection.off('reset', @render)
    @cachedModels = _.clone @collection.models
    @collection.reset()

  markDeleting: (model) =>
    model.set('deleting', true)
    element = $('.files[data-cid='+model.cid+']')
    element.children('.mm-undo').show()
    element.children('.mm-file').hide()
    for child in element.children()
      $(child).css('opacity', .1) if not $(child).hasClass('mm-undo')
    @deleteAfterDelay (model.cid)

    MeetMikey.Helper.trackResourceEvent 'deleteResource', model,
      search: @searchQuery?, currentTab: MeetMikey.Globals.tabState, rollover: false

  deleteAfterDelay: (modelId) =>
    setTimeout =>
      model = @collection.get(modelId)
      if model.get('deleting')
        @collection.remove(model)
        model.delete()
    , MeetMikey.Constants.deleteDelay

  markDeletingEvent: (event) =>
    cid = $(event.currentTarget).closest('.files').attr('data-cid')
    model = @collection.get(cid)
    @markDeleting(model)

  unMarkDeletingEvent: (event) =>
    cid = $(event.currentTarget).closest('.files').attr('data-cid')
    model = @collection.get(cid)
    @unMarkDeleting(model)

  unMarkDeleting: (model) =>
    model.set('deleting', false)
    element = $('.files[data-cid='+model.cid+']')
    element.children('.mm-undo').hide()
    element.children('.mm-file').show()
    for child in element.children()
      $(child).css('opacity', 1) if not $(child).hasClass('mm-undo')

  initialFetch: =>
    @collection.fetch success: @waitAndPoll if @options.fetch

  restoreFromCache: =>
    @collection.reset(@cachedModels)

  getTemplateData: =>
    models: _.invoke(@getModels(), 'decorate')

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

  sortByColumn: (event) =>
    field = $(event.currentTarget).attr('data-mm-field')
    @collection.sortByField(field) if field?

  setActiveColumn: =>
    field = @collection.sortKey
    target = @$("th[data-mm-field='#{field}']")
    target.addClass 'active'
    target.find('.sort-carat').addClass 'ascending' if @collection.sortOrder is 'asc'

  startRollover: (event) => @rollover.startSpawn event

  delayRollover: (event) => @rollover.delaySpawn event

  cancelRollover: => @rollover.cancelSpawn()

  setResults: (models, query) =>
    @searchQuery = query
    @rollover.setQuery query
    @collection.reset models, sort: false

  waitAndPoll: =>
    @timeoutId = setTimeout @poll, @pollDelay

  clearTimeout: =>
    clearTimeout @timeoutId if @timeoutId

  poll: =>
    data = if MeetMikey.globalUser.get('onboarding') or @collection.length < MeetMikey.Constants.paginationSize
      {}
    else
      after: @collection.latestSentDate()

    @collection.fetch
      update: true
      remove: false
      data: data
      success: @waitAndPoll
      error: @waitAndPoll
