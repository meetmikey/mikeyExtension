class MeetMikey.Model.PaginationState extends MeetMikey.Model.Base
  defaults:
    page: 0

  itemsPerPage: MeetMikey.Constants.paginationSize

  initialize: =>
    @items = @get 'items'
    @items.once 'reset', =>
      @set 'lastPage', 0 if @items.length < @itemsPerPage

  getStateData: =>
    index = @currentPageIndex()
    size = if @has('lastPage') then @items.length else 'many'

    page: @get('page') + 1
    start: index + 1
    end: Math.min(@items.length, index + @itemsPerPage)
    size: size
    firstPage: @get('page') is 0
    lastPage: @get('page') is @get('lastPage')

  # index of the first item on the current page
  currentPageIndex: =>
    @get('page') * @itemsPerPage

  getPageItems: =>
    _.chain(@items.models)
      .rest(@currentPageIndex())
      .first(@itemsPerPage)
      .value()

  nextPage: (event) =>
    return if @fetching or @onLastPage()
    if @notEnoughItems()
      @fetchNextPage()
    else
      @increment 'page', 1

  fetchNextPage: (callback) =>
    @fetching = true
    @itemsExpectedFromFetch = @itemsNeededForNextPage()
    @items.fetch
      silent: true
      update: true
      remove: false
      data:
        before: @items.earliestSentDate()
        limit: @itemsExpectedFromFetch
      success: @pageFetched

  pageFetched: (collection, response) =>
    @set 'lastPage', @get('page') + 1 if response.length < @itemsExpectedFromFetch
    @increment 'page', 1
    @fetching = false

  prevPage: (event) =>
    return unless @get('page') > 0
    @decrement 'page', 1

  onLastPage: =>
    @has('lastPage') and @get('page') >= @get('lastPage')

  notEnoughItems: =>
     @itemsNeededForNextPage() > 0

  itemsNeededForNextPage: =>
    @lastIndexOfNextPage() + 1 - @items.length

  lastIndexOfNextPage: =>
    @currentPageIndex() + 2*@itemsPerPage - 1
