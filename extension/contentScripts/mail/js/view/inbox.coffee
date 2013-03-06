template = """
    <div id="mm-tabs"></div>
    <div class="mm-attachments-tab" style="display: none;"></div>
    <div class="mm-links-tab" style="display: none;"></div>
    <div class="mm-images-tab" style="display: none;"></div>
"""

class MeetMikey.View.Inbox extends MeetMikey.View.Base
  template: Handlebars.compile(template)

  subViews:
    'attachments':
      viewClass: MeetMikey.View.Attachments
      selector: '.mm-attachments-tab'
      args: {}
    'links':
      viewClass: MeetMikey.View.Links
      selector: '.mm-links-tab'
      args: {}
    'images':
      viewClass: MeetMikey.View.Images
      selector: '.mm-images-tab'
      args: {}

  tabs:
    email: '.UI'
    attachments: '.mm-attachments-tab'
    links: '.mm-links-tab'
    images: '.mm-images-tab'

  getTabs: =>
    _.chain(@tabs).keys().without('email').value()

  preInitialize: =>
    @subViews.attachments.args.fetch = @options.fetch
    @subViews.links.args.fetch = @options.fetch
    @subViews.attachments.args.name = @options.name
    @subViews.images.args.fetch = @options.fetch

  postInitialize: =>
    @bindCountUpdate()
    # @subView('attachments').collection.on 'reset', @subView('images').setCollection
    # @subView('attachments').collection.on 'add', _.debounce ((model, collection) => @subView('images').setCollection(collection)), 50

  postRender: =>
    console.log 'inbox', @options
    # @fetchCollections() if @options.fetch

  showTab: (tab) =>
    contentSelector = _.values(@tabs).join(', ')
    $(contentSelector).hide()
    $(@tabs[tab]).show()
    @subView(tab)?.trigger 'showTab'

  bindCountUpdate: =>
    _.each @getTabs(), @bindCountUpdateForTab

  bindCountUpdateForTab: (tab) =>
    @subView(tab).on 'reset', @updateCountForTab(tab)
    @subView(tab).collection.on 'reset add remove', @updateCountForTab(tab)

  unbindCountUpdate: =>
    _.each @getTabs(), @unbindCountUpdateForTab

  unbindCountUpdateForTab: (tab) =>
    @subView(tab).off 'reset', @updateCountForTab(tab)
    @subView(tab).collection.off 'reset add remove', @updateCountForTab(tab)

  updateCountForTab: (tab) => (collection, orCollection) =>
    @trigger 'updateTabCount', tab, (collection.length || orCollection.length)

  updateTabCounts: =>
    _.each @getTabs(), (tab) =>
      console.log 'updating count for', tab, 'to', @subView(tab).collection
      @updateCountForTab(tab) @subView(tab).collection.length

  setResults: (res) =>
    console.log 'setting results'
    @subView('attachments').collection.reset res.attachments
    @subView('links').collection.reset res.links
    @subView('images').collection.reset res.images

  teardown: =>
    @unbindCountUpdate()
