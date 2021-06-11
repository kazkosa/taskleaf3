const { environment } = require('@rails/webpacker')


var webpack = require('webpack');

// environment.plugins.append(
environment.plugins.prepend(
  'Provide',
  new webpack.ProvidePlugin({
    $: 'jquery',
    jQuery: 'jquery',
    jquery: 'jquery',
    'window.jQuery': 'jquery',
    Popper: 'popper.js'
  })
)

module.exports = environment