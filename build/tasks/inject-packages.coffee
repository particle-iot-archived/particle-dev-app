path = require 'path'
fs = require 'fs-extra'
workDir = null

module.exports = (grunt) ->
  {injectPackage, injectDependency} = require('./task-helpers')(grunt)

  grunt.registerTask 'inject-packages', 'Inject packages into packages.json and node_modules dir', ->
    workDir = grunt.config.get 'particleDevApp.workDir'

    injectPackage 'file-type-icons', '1.3.3'
    injectPackage 'switch-header-source', '0.22.0'
    injectPackage 'resize-panes', '0.2.0'
    injectPackage 'maximize-panes', '0.2.0'
    injectPackage 'swap-panes', '0.2.0'
    injectPackage 'tool-bar', '1.0.1'
    injectPackage 'monokai', '0.18.0'
    injectPackage 'console-panel', '0.2.1'

    if grunt.config.get 'particleDevApp.isRelease'
      injectPackage 'particle-dev', grunt.config.get('particleDevApp.particleDevVersion')

    injectPackage 'particle-dev-release-notes', '0.53.2'
    injectPackage 'language-particle', '0.3.5'
    injectPackage 'particle-dev-exception-reporting', '0.36.1'
    injectPackage 'particle-dev-cloud-functions', '0.1.0'
    injectPackage 'particle-dev-cloud-variables', '0.1.0'
    injectPackage 'particle-dev-profiles', '0.1.15'
    injectPackage 'particle-dev-libraries', '0.2.18'

    # Following packages are required by Atom source code:
    # injectPackage 'welcome'
    # injectPackage 'metrics'
    # injectPackage 'deprecation-cop'

    # Disable folowing packages:
    injectPackage 'feedback'
    injectPackage 'release-notes'

    injectDependency 'coffeestack', 'git+https://github.com/spark/coffeestack.git#master'
