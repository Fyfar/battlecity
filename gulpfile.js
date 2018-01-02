'use strict';

var gulp = require('gulp'),
    uglify = require('gulp-uglify'),
    cssmin = require('gulp-minify-css'),
    prefixer = require('gulp-autoprefixer'),
    stylus = require('gulp-stylus'),
    watch = require("gulp-watch"),
    connect = require("gulp-connect"),
    coffee = require('gulp-coffee'),
    sourcemaps = require('gulp-sourcemaps'),
    concat = require('gulp-concat');

var path = {
    build: { //Тут мы укажем куда складывать готовые после сборки файлы
        html: 'build/',
        js: 'build/js/',
        css: 'build/css/',
        img: 'build/img/'
    },
    src: { //Пути откуда брать исходники
        html: 'src/*.html',
        libs: 'src/libs/*.js', //Libs, copy to build with no changes
        coffee: 'src/coffee/*.coffee',//В стилях и скриптах нам понадобятся только main файлы
        style: 'src/styles/*.styl',
        img: 'src/img/**/*'
    },
    watch: { //Тут мы укажем, за изменением каких файлов мы хотим наблюдать
        html: 'src/**/*.html',
        coffee: 'src/coffee/**/*.coffee',
        style: 'src/css/**/*.styl'
    },
    clean: './build'
};

gulp.task('style:build', function () {
    gulp.src(path.src.style) //Выберем наш main.css
        .pipe(stylus())
        .pipe(prefixer()) //Добавим вендорные префиксы
        .pipe(cssmin()) //Сожмем
        .pipe(gulp.dest(path.build.css)) //И в build
        .pipe(connect.reload());
});

gulp.task('js:build', function () {
    gulp.src(path.src.libs) //Найдем наш main файл
        .pipe(uglify()) //Сожмем наш js
        .pipe(gulp.dest(path.build.js)) //Выплюнем готовый файл в build
        .pipe(connect.reload()); //И перезагрузим сервер
    gulp.src(path.src.coffee)
        .pipe(sourcemaps.init())
        .pipe(coffee())
        .pipe(uglify())
        .pipe(sourcemaps.write())
        .pipe(gulp.dest(path.build.js)) //Выплюнем готовый файл в build
        .pipe(connect.reload()); //И перезагрузим сервер
});

gulp.task('html:build', function () {
    gulp.src(path.src.html) //Выберем файлы по нужному пути
        .pipe(gulp.dest(path.build.html)) //Выплюнем их в папку build
        .pipe(connect.reload()); //И перезагрузим наш сервер для обновлений
});

gulp.task('img:build', function () {
    gulp.src(path.src.img) //Выберем файлы по нужному пути
        .pipe(gulp.dest(path.build.img)) //Выплюнем их в папку build
        .pipe(connect.reload()); //И перезагрузим наш сервер для обновлений
});

gulp.task('build', [
    "html:build",
    "style:build",
    'js:build',
    'img:build'
]);

gulp.task('watch', function(){
    watch([path.watch.html], function(event, cb) {
        gulp.start('html:build');
    });
    watch([path.watch.style], function(event, cb) {
        gulp.start('style:build');
    });
    watch([path.watch.coffee], function(event, cb) {
        gulp.start('js:build');
    });
});

gulp.task('webserver', function () {
    connect.server({
        root: 'build',
        livereload: true
    });
});

gulp.task('default', ['build', 'webserver', 'watch']);