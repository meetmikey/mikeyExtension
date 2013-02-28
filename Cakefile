{spawn} = require 'child_process'
{writeFile} = require 'fs'

cssFolder = 'extension/contentScripts/mail/css'

# task 'watch', -> spawn 'coffee', ['-cw', '.'], stdio: 'inherit'
task 'compile', ->
  recess = spawn 'recess', ["#{cssFolder}/mail.less", '--compile',], stdio: ['pipe', 'pipe', process.stderr]
  recess.stdout.on 'data', (data) ->
    writeFile "#{cssFolder}/mail.css", data, (err) -> throw err if err?

task 'watch', ->
  invoke 'compile'
  spawn 'coffee', ['-cw', '.'], stdio: 'inherit'
  spawn 'recess', ["#{cssFolder}/mail.less:#{cssFolder}/mail.css", '--watch', cssFolder], stdio: 'inherit'
