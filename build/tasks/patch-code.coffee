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

  command = 'patch --binary -i ' + patchFile + ' ' + targetFile
  result = cp.exec command, (error, stdout, stderr) ->
    if error
      console.log '❌ ', patchFile, 'failed'
      out = if stdout then stdout else stderr
      console.error '\x1b[31m' + "\t" + out.replace(/\n/g, "\n\t") + '\x1b[0m'
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
        pathFile 'application-menu.patch', 'src/main-process/application-menu.coffee'
      ->
        pathFile 'atom-application.patch', 'src/main-process/atom-application.coffee'
      ->
        pathFile 'atom-environment.patch', 'src/atom-environment.coffee'
      ->
        pathFile 'atom-paths.patch', 'src/atom-paths.js'
      ->
        pathFile 'atom-window.patch', 'src/main-process/atom-window.coffee'
      ->
        pathFile 'auto-update-manager.patch', 'src/main-process/auto-update-manager.coffee'
      ->
        pathFile 'build.patch', 'script/build'
      ->
        pathFile 'code-sign-on-mac.patch', 'script/lib/code-sign-on-mac.js'
      ->
        file = path.join workDir, 'src/main-process/atom-application.coffee'
        replaceInFile file, '#{particleDevVersion}', particleDevVersion
        pathFile 'command-installer.patch', 'src/command-installer.coffee'
      ->
        pathFile 'crash-reporter-start.patch', 'src/crash-reporter-start.js'
      ->
        pathFile 'create-windows-installer.patch', 'script/lib/create-windows-installer.js'
      ->
        pathFile 'package-application.patch', 'script/lib/package-application.js'
      ->
        pathFile 'include-path-in-packaged-app.patch', 'script/lib/include-path-in-packaged-app.js'
      ->
        pathFile 'initialize-application-window.patch', 'src/initialize-application-window.coffee'
      ->
        pathFile 'start.patch', 'src/main-process/start.js'
      ->
        pathFile 'workspace.patch', 'src/workspace.js'
      ->
        if process.platform is 'darwin'
          return parallel [
            ->
              pathFile 'atom-Info.patch', 'resources/mac/atom-Info.plist'
            ->
              pathFile 'darwin.patch', 'menus/darwin.cson'
          ]
        else if process.platform is 'win32'
          # return pathFile 'win32.patch', 'menus/win32.cson'
        else if process.platform is 'linux'
          return pathFile 'linux.patch', 'menus/linux.cson'
    ]

    patchPromise.then ->
      rollbackFile.end()
      done()
    , (error) ->
      rollbackFile.end()
      done()
      # process.exit error.code
