template = """
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
    page: @page + 1

  getPageItems: =>
    _.chain(@collection.models)
      .rest(@page*@itemsPerPage)
      .first(@itemsPerPage)
      .value()

  nextPage: (event) =>
    event.preventDefault()
    return if @lastPage? and @page + 1 > @lastPage
    @page += 1
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
    @trigger 'changed:page'
