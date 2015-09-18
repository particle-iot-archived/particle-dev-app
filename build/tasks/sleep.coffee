module.exports = (grunt) ->
  grunt.registerTask 'sleep', 'Sleeps for a moment', ->
    done = @async()
    setTimeout ->
      done()
    , 1000 * 60 # Minute
