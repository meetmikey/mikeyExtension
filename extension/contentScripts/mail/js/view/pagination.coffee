template = """
  <span>{{start}}-{{end}} of {{size}}</span>
  <a href="#" class="prev-page">Prev</a>
  <span class="page-count">Page {{page}}</span>
  <a href="#" class="next-page">Next</a>
"""

class MeetMikey.View.Pagination extends MeetMikey.View.Base
  template: Handlebars.compile(template)

  events:
    'click .next-page': 'nextPage'
    'click .prev-page': 'prevPage'

  page: 0
  itemsPerPage: 50

  getTemplateData: =>
    index = @currentPageIndex()

    page: @page + 1
    start: index + 1
    end: Math.min(@collection.length, index + @itemsPerPage)
    size: @collection.length


  currentPageIndex: =>
    @page * @itemsPerPage

  getPageItems: =>
    _.chain(@collection.models)
      .rest(@page*@itemsPerPage)
      .first(@itemsPerPage)
      .value()

  nextPage: (event) =>
    event.preventDefault()
    return if @lastPage? and @page + 1 > @lastPage
    @page += 1
    @trackNextPageEvent()
    if @page * @itemsPerPage + 1 > @collection.length
      @fetchNextPage()
    else
      @trigger 'changed:page'

  fetchNextPage: (callback) =>
    @collection.fetch
      silent: true
      update: true
      remove: false
      data:
        before: @collection.last()?.get('sentDate')
        limit: @itemsPerPage
      success: @pageFetched

  pageFetched: (collection, response) =>
    @lastPage = @page if response.length < @itemsPerPage
    @trigger 'changed:page'

  prevPage: (event) =>
    event.preventDefault()
    return unless @page > 0
    @page -= 1
    @trackPrevPageEvent()
    @trigger 'changed:page'

  trackNextPageEvent: =>
    MeetMikey.Helper.Mixpanel.trackEvent 'nextPage',
      currentTab: MeetMikey.Globals.tabState, page: @page

  trackPrevPageEvent: =>
    MeetMikey.Helper.Mixpanel.trackEvent 'prevPage',
      currentTab: MeetMikey.Globals.tabState, page: @page
