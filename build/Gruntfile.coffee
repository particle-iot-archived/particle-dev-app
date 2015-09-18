path = require 'path'
fs = require 'fs-extra'
_s = require 'underscore.string'

_grunt = null
workDir = null
buildDir = null

setupDirs = ->
  if process.platform == 'win32'
    root = process.cwd().split(path.sep)[0]
    workDir = path.join(root, 'atom-work-dir')
    buildDir = path.join(root, 'particle-dev-' + process.platform)
  else
    workDir = path.join(__dirname, '..', 'dist', 'atom-work-dir')
    buildDir = path.join(__dirname, '..', 'dist', process.platform)

  if fs.existsSync(workDir) && !_grunt.option('keepAtomWorkDir')
    fs.removeSync(workDir)
  fs.ensureDirSync(workDir)

getAtomVersion = ->
  # Get Atom Version from .atomrc
  atomrc = fs.readFileSync(path.join(__dirname, '..', '.atomrc')).toString()
  lines = atomrc.split "\n"
  atomVersion = null
  for line in lines
    [key, value] = line.split '='
    if key.indexOf('ATOM_VERSION') > 0
      atomVersion = _s.trim(value)
  atomVersion

module.exports = (grunt) ->
  _grunt = grunt
  grunt.loadTasks('tasks')

  appName = 'Particle Dev'

  setupDirs()

  # Get Atom Version from .atomrc
  atomVersion = getAtomVersion()
  grunt.log.writeln '(i) Atom version is ' + atomVersion

  grunt.initConfig
    particleDevApp:
      workDir: workDir
      atomVersion: atomVersion
      appName: appName
      buildDir: buildDir

  tasks = []

  if !grunt.option('keepAtomWorkDir')
    tasks = tasks.concat [
      'get-particle-dev-version',
      'download-atom',
      'sleep',
      'patch-atom-version',
      'inject-packages',
      'bootstrap-atom',
      'install-particle-dev',
      'copy-resources',
      'patch-code',
    ]

  tasks = tasks.concat [
    'build-app',
  ]

  grunt.registerTask('default', tasks)
