spriteUrl = chrome.extension.getURL("#{MeetMikey.Constants.imgPath}/sprite.png")
openIconUrl = chrome.extension.getURL("#{MeetMikey.Constants.imgPath}/sprite.png")
driveIcon = chrome.extension.getURL("#{MeetMikey.Constants.imgPath}/google-drive-icon.png")

linkTemplate = """
  <tr class="files" data-cid="{{cid}}">

    <td class="mm-madness mm-download shift-right" {{#if deleting}}style="opacity:0.1"{{/if}}>
      <div class="mm-download-tooltip" data-toggle="tooltip" title="View email">
        <div class="inbox-icon message"></div>
      </div>
    </td>

    <td class="mm-madness mm-favorite" {{#if deleting}}style="opacity:0.1"{{/if}}>
      <div class="mm-download-tooltip" data-toggle="tooltip" title="Star">
        <div id="mm-link-favorite-{{cid}}" class="inbox-icon favorite{{#if isFavorite}}On{{/if}}"></div>
      </div>
    </td>

    <td class="mm-madness mm-like" {{#if deleting}}style="opacity:0.1"{{/if}}>
      <div class="mm-download-tooltip" data-toggle="tooltip" title="Like">
        <div id="mm-link-like-{{cid}}" class="inbox-icon like{{#if isLiked}}On{{/if}}"></div>
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
      <div class="mm-hide hide-overlay">
        <div class="close-x">Hide link</div>
      </div>
    </td>

    <td class="mm-undo truncate" {{#unless deleting}}style="display:none;{{/unless}}>
      <div class="flex">
        Link is hidden! <strong>Undo</strong> 
      </div> 
    </td>

    <td class="mm-source truncate" {{#if deleting}}style="opacity:0.1"{{/if}}><div class="inner-text">{{displayUrl}}</div></td>
    <td class="mm-from truncate" {{#if deleting}}style="opacity:0.1"{{/if}}>{{from}}</td>
    <td class="mm-to truncate" {{#if deleting}}style="opacity:0.1"{{/if}}>{{to}}</td>
    <td class="mm-sent truncate" {{#if deleting}}style="opacity:0.1"{{/if}}>{{sentDate}}</td>

  </tr>
"""

template = """
  {{#unless models}}
    <div class="mm-placeholder"></div>
  {{else}}
    <div class="section-header active">
      <div class="section-toggle">
        <div class="section-arrow active">
        </div>
        <div class="section-name active">
          {{sectionHeader}}
        </div>
      </div>
      <div class="pagination-container"></div>
      <div class="section-border"></div>
    <div class='sectionContents'>
      <table class="inbox-table search-results" id="mm-links-table" border="0">
        <thead class="labels">
          <th class="mm-download" colspan="4" data-mm-field="title">Link<div style="background-image: url('#{spriteUrl}');" class="sort-carat">&nbsp;</div></th>
          <th class="mm-file mm-link"></th>
          <th class="mm-source" data-mm-field="url">Source<div style="background-image: url('#{spriteUrl}');" class="sort-carat">&nbsp;</div></th>
          <th class="mm-from" data-mm-field="sender">From<div style="background-image: url('#{spriteUrl}');" class="sort-carat">&nbsp;</div></th>
          <th class="mm-to" data-mm-field="recipients">To<div style="background-image: url('#{spriteUrl}');" class="sort-carat">&nbsp;</div></th>
          <th class="mm-sent" data-mm-field="sentDate">Sent<div style="background-image: url('#{spriteUrl}');" class="sort-carat">&nbsp;</div></th>
        </thead>
        <tbody class="linkModelsStart">
          {{#each models}}
            """ + linkTemplate + """
          {{/each}}
        </tbody>
      </table>
      <div class="rollover-container"></div>
    </div>
  {{/unless}}
"""

class MeetMikey.View.Links extends MeetMikey.View.Base
  template: Handlebars.compile(template)
  linkTemplate: Handlebars.compile(linkTemplate)

  subViews:
    'pagination':
      selector: '.pagination-container'
      viewClass: MeetMikey.View.Pagination
      args: {}

  events:
    'click .files .mm-file': 'openLink'
    'click .files .mm-source': 'openLink'
    'click .files .mm-download': 'openMessage'
    'click .close-x' : 'markDeletingEvent'
    'click .files .mm-undo' : 'unMarkDeletingEvent'
    'click th': 'sortByColumn'
    'click .mm-favorite': 'toggleFavoriteEvent'
    'click .mm-like': 'toggleLikeEvent'
    'click .section-toggle': 'sectionToggle'
    'mouseenter .files .mm-file, .files .mm-source': 'startRollover'
    'mouseleave .files .mm-file, .files .mm-source': 'cancelRollover'
    'mousemove .files .mm-file, .files .mm-source': 'delayRollover'


  pollDelay:  MeetMikey.Constants.pollDelay
  sectionIsOpen: true

  postInitialize: =>
    @collection = new MeetMikey.Collection.Links()
    @rollover = new MeetMikey.View.LinkRollover collection: @collection, search: !@options.fetch

    @collection.on 'reset', @render
    @collection.on 'delete', @markDeleting
    @collection.on 'undoDelete', @unMarkDeleting

    @paginationState = new MeetMikey.Model.PaginationState items: @collection
    @paginationState.on 'change:page', @render
    @subView('pagination').setState @paginationState

    MeetMikey.globalEvents.on 'favoriteOrLikeEvent', @favoriteOrLikeEvent

  postRender: =>
    @rollover.setElement @$('.rollover-container')
    $('.mm-download-tooltip').tooltip placement: 'bottom'
    @setActiveColumn()

  setFetch: (isFetch) =>
    @options.fetch = isFetch
    if @isSearch()
      @subView('pagination').options.render = false
      @subView('pagination').render()

  favoriteOrLikeEvent: (actionType, resourceType, resourceId, value) =>
    if resourceType isnt 'link'
      return
    link = @collection.get resourceId
    if not link
      return
    if actionType is 'favorite'
      link.set 'isFavorite', value
      if @options.isFavorite and value is true
        return
      if not @options.isFavorite and value is false
        return
      if @isSearch()
        elementId = '#mm-link-favorite-' + link.cid
        MeetMikey.Helper.FavoriteAndLike.updateModelLikeDisplay link, elementId
      else
        @moveModelToOtherSubview link
    else if actionType is 'like'
      link.set 'isLiked', value
      elementId = '#mm-link-like-' + link.cid
      MeetMikey.Helper.FavoriteAndLike.updateModelLikeDisplay link, elementId

  isSearch: =>
    not @options.fetch

  teardown: =>
    @clearTimeout()
    @cachedModels = _.clone @collection.models
    @collection.off 'reset', @render
    @collection.reset()
    @collection.on 'reset', @render #Apparently we have to put this back on.  Not sure why teardown took it off, really.

  sectionToggle: (event) =>
    if @sectionIsOpen
      @sectionIsOpen = false
      @$('.sectionContents').hide()
      @$('.section-arrow').removeClass 'active'
    else
      @sectionIsOpen = true
      @$('.sectionContents').show()
      @$('.section-arrow').addClass 'active'

  toggleFavoriteEvent: (event) =>
    event.preventDefault()
    cid = $(event.currentTarget).closest('.files').attr('data-cid')
    model = @collection.get(cid)
    MeetMikey.Helper.FavoriteAndLike.toggleFavorite model, null, 'tab'

  toggleLikeEvent: (event) =>
    event.preventDefault()
    cid = $(event.currentTarget).closest('.files').attr('data-cid')
    model = @collection.get(cid)
    elementId = '#mm-link-like-' + model.cid
    MeetMikey.Helper.FavoriteAndLike.toggleLike model, elementId, 'tab'

  removeModel: (model) =>
    if not model
      return
    element = @$('.files[data-cid='+model.cid+']')
    element.remove()
    @collection.remove model

  addModel: (model) =>
    if not model
      return

    @collection.add model
    if @collection.length is 1
      @render()
      return

    decoratedModel = model.decorate()
    html = @linkTemplate decoratedModel

    myIndex = @collection.models.indexOf model
    if myIndex is -1
      return
    if myIndex is ( @collection.length - 1 )
      @$('.linkModelsStart').append html
    else
      nextModel = @collection.at (myIndex + 1)
      if not nextModel
        return
      @$('.files[data-cid='+nextModel.cid+']').before html

  moveModelToOtherSubview: (model) =>
    if @isSearch()
      return
    @removeModel model
    if model.get('isFavorite')
      @parentView.subView('linksFavorite').addModel model
    else
      @parentView.subView('links').addModel model

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

  deleteAfterDelay: (modelCId) =>
    setTimeout =>
      model = @collection.get(modelCId)
      if model and model.get('deleting')
        @collection.remove(model)
        model.delete()
    , MeetMikey.Constants.deleteDelay

  markDeletingEvent: (event) =>
    event.preventDefault()
    cid = $(event.currentTarget).closest('.files').attr('data-cid')
    model = @collection.get(cid)
    @markDeleting(model)
    false

  unMarkDeletingEvent: (event) =>
    event.preventDefault()
    cid = $(event.currentTarget).closest('.files').attr('data-cid')
    model = @collection.get(cid)
    @unMarkDeleting(model)
    false

  unMarkDeleting: (model) =>
    model.set('deleting', false)
    element = $('.files[data-cid='+model.cid+']')
    element.children('.mm-undo').hide()
    element.children('.mm-file').show()
    for child in element.children()
      $(child).css('opacity', 1) if not $(child).hasClass('mm-undo')

  initialFetch: =>
    if @isSearch()
      return
    @collection.fetch
      data:
        isFavorite: @options.isFavorite?
      success: @waitAndPoll

  restoreFromCache: =>
    @collection.reset(@cachedModels)

  areFavoritesInView: =>
    areFavoritesInView = false
    if @parentView.subView('linksFavorite')
      models = @parentView.subView('linksFavorite').getModels()
      if models and models.length
        areFavoritesInView = true
    areFavoritesInView

  getTemplateData: =>

    sectionHeader = 'Everything'
    if @areFavoritesInView()
      sectionHeader += ' else'
    if @options.isFavorite
      sectionHeader = 'Starred'

    object = {}
    object.models = _.invoke(@getModels(), 'decorate')
    object.openIconUrl = openIconUrl
    object.sectionHeader = sectionHeader
    object

  getModels: =>
    if @options.fetch
      @paginationState.getPageItems()
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
    threadHex = MeetMikey.Helper.decimalToHex( model.get 'gmThreadId' )
    if @options.fetch
      hash = "#inbox/#{threadHex}"
    else
      hash = "#search/#{@searchQuery}/#{threadHex}"

    MeetMikey.Helper.trackResourceEvent 'openMessage', model,
      currentTab: MeetMikey.Globals.tabState, search: !@options.fetch, rollover: false

    MeetMikey.Helper.Url.setHash hash

  sortByColumn: (event) =>
    field = $(event.currentTarget).attr('data-mm-field')
    @collection.sortByField(field) if field?
    @render()

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
    if @timeoutId
      return
    @timeoutId = setTimeout () =>
      @timeoutId = null
      @poll()
    , @pollDelay

  clearTimeout: =>
    if @timeoutId
      clearTimeout @timeoutId

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
