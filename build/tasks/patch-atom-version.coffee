path = require 'path'
fs = require 'fs-extra'

workDir = null

module.exports = (grunt) ->
  grunt.registerTask 'patch-atom-version', 'Patches Atom version', ->
    packageJson = path.join(grunt.config.get('particleDevApp.workDir'), 'package.json')
    packages = JSON.parse(fs.readFileSync(packageJson))
    packages.version = grunt.config.get('particleDevApp.particleDevVersion')
    fs.writeFileSync(packageJson, JSON.stringify(packages, null, '  '))
