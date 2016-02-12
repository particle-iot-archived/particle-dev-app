path = require 'path'
fs = require 'fs-extra'
workDir = null

copyResource = (from, to) ->
  to = to.replace '/', path.sep
  fs.copySync path.join(__dirname, '..', 'resources', from),
              path.join(workDir, to)

module.exports = (grunt) ->
  grunt.registerTask 'copy-resources', 'Copies resources', ->
    workDir = grunt.config.get 'particleDevApp.workDir'

    copyResource 'atom.png', 'resources/atom.png'
    copyResource 'config.cson', 'dot-atom/config.cson'

    if process.platform is 'darwin'
      copyResource 'particle-dev.icns', 'resources/app-icons/stable/atom.icns'
    else if process.platform is 'win32'
      copyResource 'particle-dev.ico', 'resources/app-icons/stable/atom.ico'
      copyResource 'loading.gif', 'resources/win/loading.gif'
