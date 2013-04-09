class DOMManager
  maxTries: 10

  find: (selector) =>
    target = $(selector)
    @notFoundError(selector) unless target.length > 0
    target

  waitAndFind: (selector, callback) =>
    tries = 0
    find = ->
      tries += 1
      if tries > @maxTries
        console.log "CANNOT find #{selectors} after #{tries} attempts"
        return
      else
        target = $(selector)
        if target.length > 0
          callback target
        else setTimeout find, 200
    find()

  waitAndFindAll: (selectors..., callback) =>
    tries = 0
    find = ->
      console.log 'finding'
      tries += 1
      if tries > @maxTries
        console.log "CANNOT find #{selectors} after #{tries} attempts"
        return
      else
        targets = _.map selectors, (s) -> $ s
        if _.every(targets, (target) -> target.length > 0)
          callback targets
        else setTimeout find, 200
    find()


  injectInto: (selector, content, callback) =>
    tries = 0
    elem = $(content)
    tryFind = _.partial @waitAndFind, selector, (target) =>

      if @existsIn target, elem
        tries += 1
        if tries > @maxTries
          console.log "another container already exists", elem
          return
        else setTimeout tryFind, 200
      else
        target.append(content)
        callback?()
    tryFind()

  injectBeside: (selector, content, callback) =>
    tries = 0
    elem = $(content)

    tryFind = _.partial @waitAndFind, selector, (target) =>

      if @existsBeside target, elem
        tries += 1
        if tries > @maxTries
          console.log "another container already exists", elem
          return
        else setTimeout tryFind, 200
      else
        target.before(content)
        callback?()
    tryFind()

  existsIn: (target, elem) =>
    _.any target.children(), (child) ->
      $(child).hasClass elem.attr('class')


  existsBeside: (target, elem) =>
    _.any target.siblings(), (sibling) ->
      $(sibling).hasClass elem.attr('class')

  stripDOM: =>
    root = $('body').clone()
    # remove all text nodes (cannot get iframe contents from detached root)
    root.find('*').not('iframe').contents().filter(-> @nodeType is 3).remove()
    root.find('[email]').attr('email', '')
    root.find('[name]').attr('name', '')

    root.html()

  notFoundError: (selector) =>
    data = {selector}
    data.dom = @stripDOM() if @sendDOM()

    MeetMikey.Helper.callDebug 'selectorNotFound', data

    MeetMikey.Helper.LocalStore.set 'selectorNotFound',
      version: MeetMikey.Settings.extensionVersion, timestamp: Date.now()


  sendDOM: =>
    lastError = MeetMikey.Helper.LocalStore.get 'selectorNotFound'
    return true unless lastError?

    lastError.version isnt MeetMikey.Settings.extensionVersion or
    MeetMikey.Helper.hoursSince(lastError.timestamp) >= 24


MeetMikey.Helper.DOMManager = new DOMManager()
