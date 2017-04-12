cp = require '../../script/utils/child-process-wrapper.js'
path = require 'path'
whenjs = require 'when'
sequence = require 'when/sequence'
workDir = null
_grunt = null

module.exports = (grunt) ->
  _grunt = grunt
  grunt.registerTask 'build-app', 'Builds executable', ->
    done = @async()
    workDir = grunt.config.get('particleDevApp.workDir')

    # Run Atom's build script
    process.chdir(workDir)
    params = ['script/build']

    if process.platform is 'win32'
      params.push('--code-sign', '--create-windows-installer')
    else if process.platform is 'darwin'
      params.push('--code-sign', '--compress-artifacts')

    cp.safeSpawn 'node', params, (result) ->
      done()
