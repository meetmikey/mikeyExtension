@javascript 'scripts', ->
  @options
    build: './build/js'

  # @javascript './extension/lib/js/', output: './extension/lib/js/'
  @coffeescript './extension', output: './extension'

@stylesheets 'styles', ->
  @options
    build: './build/css'

  @css './extension/lib/css', output: './extension/lib/css'
  @less './extension/contentScripts/mail/css', output: './extension/contentScripts/mail/css'
