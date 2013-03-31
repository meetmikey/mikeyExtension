class MeetMikey.Model.PaginationState extends MeetMikey.Model.Base
  defaults:
    page: 0

  itemsPerPage: 50

  initialize: =>
    @items = @get 'items'

  getStateData: =>
    index = @currentPageIndex()
    size = if @has('lastPage') then @items.length else 'many'

    page: @get('page') + 1
    start: index + 1
    end: Math.min(@items.length, index + @itemsPerPage)
    size: size

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
    @items.fetch
      silent: true
      update: true
      remove: false
      data:
        before: @items.last()?.get('sentDate')
        limit: @itemsPerPage
      success: @pageFetched

  pageFetched: (collection, response) =>
    @set 'lastPage', @get('page') + 1 if response.length < @itemsPerPage
    @increment 'page', 1
    @fetching = false

  prevPage: (event) =>
    return unless @get('page') > 0
    @decrement 'page', 1

  onLastPage: =>
    @has('lastPage') and @get('page') >= @get('lastPage')

  notEnoughItems: =>
    @currentPageIndex() + @itemsPerPage >= @items.length
