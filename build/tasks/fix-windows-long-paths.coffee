path = require 'path'
fs = require 'fs-extra'

module.exports = (grunt) ->
  grunt.registerTask 'fix-windows-long-paths', 'Moves nested packages up', ->
  	if process.platform is 'win32'
      workDir = grunt.config.get 'particleDevApp.workDir'
      fs.removeSync "#{workDir}\\node_modules\\particle-dev-libraries\\node_modules\\particle-commands\\node_modules\\yeoman-generator\\node_modules\\yeoman-test"
      fs.removeSync "#{workDir}\\node_modules\\particle-dev-libraries\\node_modules\\particle-commands\\node_modules\\yeoman-environment\\node_modules\\inquirer"
