class DOMManager
  maxTries: 10

  find: (selector, callback) =>
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

  findAll: (selectors..., callback) =>
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
    tryFind = _.partial @find, selector, (target) =>

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

    tryFind = _.partial @find, selector, (target) =>

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

MeetMikey.Helper.DOMManager = new DOMManager()
