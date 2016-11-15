/**
 * Created by soga on 16/10/18.
 */
var rollup = require('rollup');
var babel = require('rollup-plugin-babel');
var uglify = require('rollup-plugin-uglify');
var npm = require('rollup-plugin-node-resolve');
var commonjs = require('rollup-plugin-commonjs');
rollup.rollup({
    entry: 'src/js/app.js',
    plugins: [
        npm({ jsnext: true, main: true }),
        commonjs(),
        babel({
            exclude: 'node_modules/**',
            presets: [ "es2015-rollup" ]
        })
    ]
}).then(function(bundle) {
    bundle.write({
        format: 'cjs',
        dest: 'dist/js/app.js'
    });
});