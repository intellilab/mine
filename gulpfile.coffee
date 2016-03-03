gulp = require 'gulp'
concat = require 'gulp-concat'
coffee = require 'gulp-coffee'
order = require 'gulp-order'

gulp.task 'coffee', ->
  gulp.src 'src/**/*.coffee'
    .pipe order [
      '!**/app.coffee'
    ]
    .pipe concat 'app.js'
    .pipe do coffee
    .pipe gulp.dest 'dist'

gulp.task 'css', ->
  gulp.src 'src/**/*.css'
    .pipe concat 'app.css'
    .pipe gulp.dest 'dist'

gulp.task 'copy', ->
  gulp.src 'src/index.html'
    .pipe gulp.dest 'dist'

gulp.task 'default', ['coffee', 'css', 'copy']

gulp.task 'watch', ->
  gulp.watch 'src/**/*.coffee', ['coffee']
  gulp.watch 'src/**/*.css', ['css']
  gulp.watch 'src/index.html', ['copy']
