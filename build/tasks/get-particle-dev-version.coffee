request = require 'request'

_grunt = null
isRelease = true

getParticleDevVersion = (cb) ->
  # Get Particle Dev version from options/current sources
  if !!_grunt.option('particleDevVersion')
    cb _grunt.option('particleDevVersion')
  else if (!!process.env.TRAVIS_TAG or !!process.env.APPVEYOR_REPO_TAG_NAME) and !!process.env.PARTICLE_DEV_VERSION
    cb process.env.PARTICLE_DEV_VERSION
  else
    isRelease = false
    # Get the version from master
    repo = 'spark/spark-dev'
    url = "https://raw.githubusercontent.com/#{repo}/master/package.json"
    request url, (error, response, body) ->
      if !!error
        _grunt.fail.fatal '(e) Error fetching version'
      version = JSON.parse(body).version

      # Fetch latest commit
      token = process.env.ATOM_ACCESS_TOKEN
      options =
        url: "https://api.github.com/repos/#{repo}/commits?sha=master"
        headers:
          Authorization: "token #{token}"
          'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.93 Safari/537.36'

      _grunt.log.writeln "Fetching version from #{options.url}"
      request options, (error, response, body) ->
        if !!error
          _grunt.fail.fatal '(e) Error fetching commits'
        console.log '-->', body
        console.log '-->', response
        console.log '-->', error
        version = "#{version}-" + JSON.parse(body)[0].sha.substring(0, 7)
        cb version

module.exports = (grunt) ->
  grunt.registerTask 'get-particle-dev-version', 'Figures Particle Dev version', ->
    done = @async()
    _grunt = grunt

    getParticleDevVersion (particleDevVersion) ->
      grunt.log.writeln '(i) Particle Dev version is ' + particleDevVersion
      grunt.config.merge
        particleDevApp:
          particleDevVersion: particleDevVersion
          isRelease: isRelease

      done()
