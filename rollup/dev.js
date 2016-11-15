// Rollup plugins.
import buble from 'rollup-plugin-buble'
import cjs from 'rollup-plugin-commonjs'
import globals from 'rollup-plugin-node-globals'
import replace from 'rollup-plugin-replace'
import resolve from 'rollup-plugin-node-resolve'

export default {
  dest: 'build/app.js',
  entry: 'src/js/app.js',
  format: 'iife',
  plugins: [
    buble(),
    cjs({
      exclude: 'node_modules/process-es6/**',
      include: []
    }),
    globals(),
    replace({ 'process.env.NODE_ENV': JSON.stringify('development') }),
    resolve({
      browser: true,
      main: true
    })
  ],
  sourceMap: true
}
