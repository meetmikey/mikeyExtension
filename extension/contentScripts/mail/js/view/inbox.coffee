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

  tabs:
    email: '.UI'
    attachments: '.mm-attachments-tab'
    links: '.mm-links-tab'
    images: '.mm-images-tab'

  getTabs: =>
    _.chain(@tabs).keys().without('email').value()

  preInitialize: =>
    console.log 'inbox subview', @subViews
    console.log 'inbox options', @options
    @subViews.attachments.args.fetch = @options.fetch
    @subViews.links.args.fetch = @options.fetch
    @subViews.attachments.args.name = @options.name

  postInitialize: =>
    @bindCountUpdate()
    @subView('attachments').collection.on 'reset', @subView('images').setCollection

  postRender: =>
    console.log 'inbox', @options
    # @fetchCollections() if @options.fetch

  showTab: (tab) =>
    contentSelector = _.values(@tabs).join(', ')
    $(contentSelector).hide()
    @$(@tabs[tab]).show()
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

  updateCountForTab: (tab) => (collection) =>
    @trigger 'updateTabCount', tab, collection.length

  updateTabCounts: =>
    _.each @getTabs(), (tab) =>
      console.log 'updating count for', tab, 'to', @subView(tab).collection
      @updateCountForTab(tab) @subView(tab).collection.length

  setResults: (res) =>
    console.log 'setting results'
    @subView('attachments').collection.reset res.attachments
    @subView('links').collection.reset res.links

  teardown: =>
    @unbindCountUpdate()
