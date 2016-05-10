path = require 'path'
fs = require 'fs-extra'
request = require 'request'
Decompress = require 'decompress'
cp = require '../../script/utils/child-process-wrapper.js'
_s = require 'underscore.string'

workDir = null
_grunt = null
injectPackage = null


installDependencies = (particleDevPath, done) ->
  # Build serialport
  packageJson = path.join(workDir, 'package.json')
  packages = JSON.parse(fs.readFileSync(packageJson))
  process.chdir(particleDevPath);
  env = process.env
  env['ATOM_NODE_VERSION'] = packages.electronVersion
  env['ATOM_HOME'] = if process.platform is 'win32' then process.env.USERPROFILE else process.env.HOME
  options = {
    env: env
  }

  if process.platform == 'win32'
    command = '..\\..\\apm\\node_modules\\atom-package-manager\\bin\\apm.cmd'
  else
    command = '../../apm/node_modules/atom-package-manager/bin/apm'

  verbose = if !_grunt.option('verbose') then '' else ' --verbose'
  cp.safeExec command + ' install' + verbose, options, ->
    injectPackage 'particle-dev', packages.version
    done()

module.exports = (grunt) ->
  {injectPackage, copyExcluding} = require('./task-helpers')(grunt)
  _grunt = grunt

  grunt.registerTask 'install-particle-dev', 'Installs Particle Dev package', ->
    done = @async()

    if grunt.config.get('particleDevApp.isRelease')
      return done()

    workDir = grunt.config.get('particleDevApp.workDir')
    particleDevPath = path.join(workDir, 'node_modules', 'particle-dev')

    # Download the release
    tarballUrl = 'https://github.com/spark/particle-dev/archive/master.tar.gz'
    tarballPath = path.join(workDir, 'particledev.tar.gz')

    r = request(tarballUrl)
    r.on 'end', ->
      decompress = new Decompress()
      decompress.src tarballPath
      decompress.dest particleDevPath
      decompress.use(Decompress.targz({ strip: 1 }))
      decompress.run (error) ->
        if error
          throw error

        fs.unlinkSync tarballPath
        fs.removeSync path.join(particleDevPath, 'docs')

        installDependencies particleDevPath, done

    r.pipe(fs.createWriteStream(tarballPath))
