@javascript 'scripts', ->
  @options
    build: './build/js'

  @javascript './extension/lib/js/', output: './extension/lib/js/'
  @coffeescript './extension/contentScripts/mail/js', output: './extension/contentScripts/mail/js'

@stylesheets 'styles', ->
  @options
    build: './build/css'

  @css './extension/lib/css', output: './extension/lib/css'
  @less './extension/contentScripts/mail/css', output: './extension/contentScripts/mail/css'
