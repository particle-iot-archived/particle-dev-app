fs = require 'fs-extra'
path = require 'path'
cp = require 'child_process'
whenjs = require 'when'
parallel = require 'when/parallel'

workDir = null
rollbackFile = null

pathFile = (patchFile, targetFile) ->
  dfd = whenjs.defer()
  patchFile = path.join(__dirname, 'patches', patchFile)
  targetFile = path.join(workDir, targetFile.replace('/', path.sep))

  command = 'patch -i ' + patchFile + ' ' + targetFile
  result = cp.exec command, (error, stdout, stderr) ->
    if error
      console.log '❌ ', patchFile, 'failed'
      console.error '\x1b[31m' + "\t" + stdout.replace(/\n/g, "\n\t") + '\x1b[0m'
      dfd.reject error
    else
      console.log '✅ ', patchFile, 'applied'
      rollbackFile.write "echo \"Rolling back #{targetFile}\"\n"
      rollbackFile.write "mv #{targetFile}.orig #{targetFile}\n"
      dfd.resolve()
  dfd.promise

replaceInFile = (file, substr, newSubstr) ->
  file = file.replace('/', path.sep)
  contents = fs.readFileSync(file).toString()
  contents = contents.replace substr, newSubstr
  fs.writeFileSync file, contents

module.exports = (grunt) ->
  grunt.registerTask 'patch-code', 'Patches Atom code', ->
    workDir = grunt.config.get('particleDevApp.workDir')
    particleDevVersion = grunt.config.get('particleDevApp.particleDevVersion')
    rollbackFile = fs.createWriteStream(path.join(workDir, 'rollbackPatches.sh'))
    rollbackFile.write "#!/bin/bash\n"
    done = @async()

    # Remove broken spec
    fs.removeSync path.join(workDir, 'node_modules', 'coffeestack', 'spec')
    fs.removeSync path.join(workDir, 'node_modules', 'exception-reporting', 'node_modules', 'coffeestack', 'spec')

    # Patching
    patchPromise = parallel [
      ->
        pathFile 'atom-application.patch', 'src/main-process/atom-application.coffee'
      ->
        file = path.join workDir, 'src/main-process/atom-application.coffee'
        replaceInFile file, '#{particleDevVersion}', particleDevVersion
        pathFile 'command-installer.patch', 'src/command-installer.coffee'
      ->
        pathFile 'main.patch', 'src/main-process/main.js'
      ->
        pathFile 'auto-update-manager.patch', 'src/main-process/auto-update-manager.coffee'
      ->
        pathFile 'application-menu.patch', 'src/main-process/application-menu.coffee'
      ->
        pathFile 'atom-window.patch', 'src/main-process/atom-window.coffee'
      ->
        pathFile 'crash-reporter-start.patch', 'src/crash-reporter-start.js'
      ->
        pathFile 'workspace.patch', 'src/workspace.coffee'
      ->
        pathFile 'Gruntfile.patch', 'build/Gruntfile.coffee'
      ->
        pathFile 'codesign-task.patch', 'build/tasks/codesign-task.coffee'
      ->
        pathFile 'publish-build-task.patch', 'build/tasks/publish-build-task.coffee'
      ->
        pathFile 'set-version-task.patch', 'build/tasks/set-version-task.coffee'
      ->
        pathFile 'license-overrides.patch', 'build/tasks/license-overrides.coffee'
      ->
        pathFile 'bootstrap.patch', 'script/bootstrap'
      ->
        if process.platform is 'darwin'
          return parallel [
            ->
              pathFile 'atom-Info.patch', 'resources/mac/atom-Info.plist'
            ->
              pathFile 'darwin.patch', 'menus/darwin.cson'
          ]
        else if process.platform is 'win32'
          return pathFile 'win32.patch', 'menus/win32.cson'
        else
          return pathFile 'linux.patch', 'menus/linux.cson'
    ]

    patchPromise.then ->
      rollbackFile.end()
      done()
    , (error) ->
      rollbackFile.end()
      done()
      # process.exit error.code
