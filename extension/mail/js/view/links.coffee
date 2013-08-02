spriteUrl = chrome.extension.getURL("#{MeetMikey.Constants.imgPath}/sprite.png")
openIconUrl = chrome.extension.getURL("#{MeetMikey.Constants.imgPath}/sprite.png")
driveIcon = chrome.extension.getURL("#{MeetMikey.Constants.imgPath}/google-drive-icon.png")
favoriteOnURL = chrome.extension.getURL("#{MeetMikey.Constants.imgPath}/favoriteOn.jpg")
favoriteOffURL = chrome.extension.getURL("#{MeetMikey.Constants.imgPath}/favoriteOff.png")

template = """
  {{#unless models}}
    <div class="mm-placeholder"></div>
  {{else}}
    <div class="pagination-container"></div>
    <table class="inbox-table search-results" id="mm-links-table" border="0">
      <thead class="labels">
        <th class="mm-download" colspan="4" data-mm-field="title">Link<div style="background-image: url('#{spriteUrl}');" class="sort-carat">&nbsp;</div></th>
        <th class="mm-file mm-link"></th>
        <th class="mm-source" data-mm-field="url">Source<div style="background-image: url('#{spriteUrl}');" class="sort-carat">&nbsp;</div></th>
        <th class="mm-from" data-mm-field="sender">From<div style="background-image: url('#{spriteUrl}');" class="sort-carat">&nbsp;</div></th>
        <th class="mm-to" data-mm-field="recipients">To<div style="background-image: url('#{spriteUrl}');" class="sort-carat">&nbsp;</div></th>
        <th class="mm-sent" data-mm-field="sentDate">Sent<div style="background-image: url('#{spriteUrl}');" class="sort-carat">&nbsp;</div></th>
      </thead>
      <tbody>
        {{#each models}}
          <tr class="files" data-cid="{{cid}}">
            <td class="mm-hide" {{#if deleting}}style="opacity:0.1"{{/if}}>
              <div class="mm-download-tooltip" data-toggle="tooltip" title="Hide this link">
                <a href="#"><div class="close-x">x</div></a>
              </div>
            </td>
            <td class="mm-download" {{#if deleting}}style="opacity:0.1"{{/if}}>
              <div class="list-icon mm-download-tooltip" data-toggle="tooltip" title="View email">
                <div class="list-icon" style="background-image: url('#{spriteUrl}');"></div>
              </div>
            </td>

            <td class="mm-favorite" {{#if deleting}}style="opacity:0.1"{{/if}}>
              <div class="mm-favorite-tooltip" data-toggle="tooltip" title="Toggle favorite">
                <div class="sidebar-icon favorite{{#if isFavorite}}On{{/if}}"></div>
              </div>
            </td>
         
            {{#if isGoogleDoc}}
              <td class="mm-favicon" style="background:url('#{driveIcon}') no-repeat;">&nbsp;</td>
            {{else}}
              <td class="mm-favicon" style="background:url({{faviconURL}}) no-repeat;">&nbsp;</td>
            {{/if}}

            <td class="mm-file truncate" {{#if deleting}}style="display:none;{{/if}}>
              <div class="flex">
                {{title}}
                <span class="mm-file-text">{{summary}}</span>
              </div>
            </td>
            <td class="mm-undo truncate" {{#unless deleting}}style="display:none;{{/unless}}>
              <div class="flex">
                Link is hidden! <strong>Undo</strong> 
              </div>
            </td>
            <td class="mm-source truncate" {{#if deleting}}style="opacity:0.1"{{/if}}>{{displayUrl}}</td>
            <td class="mm-from truncate" {{#if deleting}}style="opacity:0.1"{{/if}}>{{from}}</td>
            <td class="mm-to truncate" {{#if deleting}}style="opacity:0.1"{{/if}}>{{to}}</td>
            <td class="mm-sent truncate" {{#if deleting}}style="opacity:0.1"{{/if}}>{{sentDate}}</td>
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
    'click .files .mm-file': 'openLink'
    'click .files .mm-source': 'openLink'
    'click .files .mm-download': 'openMessage'
    'click .close-x' : 'markDeletingEvent'
    'click .files .mm-undo' : 'unMarkDeletingEvent'
    'click th': 'sortByColumn'
    'click .mm-favorite': 'toggleFavoriteEvent'
    'mouseenter .files .mm-file, .files .mm-source': 'startRollover'
    'mouseleave .files .mm-file, .files .mm-source': 'cancelRollover'
    'mousemove .files .mm-file, .files .mm-source': 'delayRollover'


  pollDelay:  MeetMikey.Constants.pollDelay

  postInitialize: =>
    @collection = new MeetMikey.Collection.Links()
    @rollover = new MeetMikey.View.LinkRollover collection: @collection, search: !@options.fetch
    @pagination = new MeetMikey.Model.PaginationState items: @collection

    @collection.on 'reset add remove', _.debounce(@render, MeetMikey.Constants.paginationSize)
    @collection.on 'sort', @render
    @pagination.on 'change:page', @render
    @collection.on 'remove', @render
    @collection.on 'delete', @markDeleting
    @collection.on 'undoDelete', @unMarkDeleting

  postRender: =>
    @rollover.setElement @$('.rollover-container')
    $('.mm-download-tooltip').tooltip placement: 'bottom'
    @setActiveColumn()

  isSearch: =>
    not @options.fetch

  teardown: =>
    @clearTimeout()
    @collection.off 'reset', @render
    @cachedModels = _.clone @collection.models
    @collection.reset()

  toggleFavoriteEvent: (event) =>
    event.preventDefault()
    cid = $(event.currentTarget).closest('.files').attr('data-cid')
    model = @collection.get(cid)
    @toggleFavorite(model)

  toggleFavorite: (model) =>
    oldIsFavorite = model.get('isFavorite')
    newIsFavorite = true
    if oldIsFavorite
      newIsFavorite = false
    model.set 'isFavorite', newIsFavorite
    model.putIsFavorite newIsFavorite, (response, status) =>
      if status == 'success'
        if not @isSearch()
          @moveModelToOtherSubview model
        else
          @renderTemplate()
      else
        console.log 'putIsFavorite failed'

  moveModelToOtherSubview: (model) =>
    @collection.remove model
    if @options.isFavorite
      @parentView.subView('links').collection.add model
    else
      @parentView.subView('linksFavorite').collection.add model

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
    event.preventDefault()
    cid = $(event.currentTarget).closest('.files').attr('data-cid')
    model = @collection.get(cid)
    @markDeleting(model)

  unMarkDeletingEvent: (event) =>
    event.preventDefault()
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
    if @options.fetch
      @collection.fetch
        data:
          isFavorite: @options.isFavorite?
        success: @waitAndPoll

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

    MeetMikey.Helper.Url.setHash hash

  sortByColumn: (event) =>
    field = $(event.currentTarget).attr('data-mm-field')
    @collection.sortByField(field) if field?

  setActiveColumn: =>
    field = @collection.sortKey
    target = @$("th[data-mm-field='#{field}']")
    target.addClass 'active'
    target.find('.sort-carat').addClass 'ascending' if @collection.sortOrder is 'asc'

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

    data.isFavorite = @options.isFavorite?

    @collection.fetch
      update: true
      remove: false
      data: data
      success: @waitAndPoll
      error: @waitAndPoll
