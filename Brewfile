# use Grunt.js in future for more robust asset build process
# eg. minification, compilation, etc
@javascript 'scripts', ->
  @options
    build: './build/js'

  # @javascript './extension/lib/js/', output: './extension/lib/js/'
  @coffeescript './extension', output: './extension'

@stylesheets 'styles', ->
  @options
    build: './build/css'

  @css './extension/lib/css', output: './extension/lib/css'
  @less './extension/mail/css', output: './extension/mail/css'
