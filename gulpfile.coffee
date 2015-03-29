gulp        = require 'gulp'
gulpLoad    = require 'gulp-load-plugins'
browserSync = require 'browser-sync'
yargs       = require('yargs')
plugins     = gulpLoad()
reload      = browserSync.reload
argv        = yargs.argv

settings =
  server: 
    nosync:   if argv.nosync then true else false
    port:     8090
  sass: 
    compress: true
  jade:
    compress: true

paths =
    root:    './'
    assets:  './assets/'
    vendors: './vendors/'
    jade:    './src/jade/'
    sass:    './src/sass/'
    coffee:  './src/coffee/'
    output:  './dist/'

#
# Jade
# 
gulp.task 'jade', ->
  gulp.src(paths.jade + 'pages/**/*.jade')
    .pipe plugins.plumber()
    .pipe plugins.jade
        pretty: if settings.jade.compress then false else true
    .pipe gulp.dest paths.output

#
# Sass + sourcemaps
# 
gulp.task 'sass', ->
  gulp.src paths.sass + '**/*.{sass,scss}'
    .pipe plugins.plumber()
    .pipe plugins.sourcemaps.init()
    .pipe plugins.sass 
      errLogToConsole: true
      indentedSyntax:  true
      outputStyle:     if settings.sass.compress then 'compressed' else 'expanded'
    .pipe plugins.autoprefixer()
    .pipe plugins.sourcemaps.write('.')
    .pipe gulp.dest paths.output + 'css/'

#
# Coffee + sourcemaps
# 
gulp.task 'coffee', ->
  gulp.src(paths.coffee + '**/*.coffee')
    .pipe plugins.plumber()
    .pipe plugins.sourcemaps.init()
    .pipe plugins.coffee
      sourceMap: true
    .pipe plugins.concat 'app.js'
    .pipe plugins.uglify()
    .pipe plugins.sourcemaps.write('.')
    .pipe gulp.dest paths.output + 'js/'

#
# Copy vendors
# 
gulp.task 'vendors', ->
  gulp.src paths.vendors + '**/*'
    .pipe gulp.dest paths.output + 'vendors/'

#
# Copy vendors
# 
gulp.task 'assets', ->
  gulp.src paths.assets + '**/*'
    .pipe gulp.dest paths.output

#
# Serve with Browser Sync
# 
gulp.task 'browsersync', ->
  browserSync  
    port:      settings.server.port
    server:    paths.output
    ghostMode: !settings.server.nosync

#
# Watch
# 
gulp.task 'watch', ->
  gulp.watch paths.vendors + '**/*',        [ 'vendors', reload ]
  gulp.watch paths.sass    + '**/*.*',      [ 'sass',    reload ]
  gulp.watch paths.jade    + '**/*.jade',   [ 'jade',    reload ]
  gulp.watch paths.coffee  + '**/*.coffee', [ 'coffee',  reload ]

#
# Build
# 
gulp.task 'build', [ 
  'coffee' 
  'jade' 
  'sass'
  'assets'
  'vendors'
]

#
# Default task
# 
gulp.task 'default', [ 
  'build', 
  'watch', 
  'browsersync'
]
