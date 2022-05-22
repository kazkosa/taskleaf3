const path = require('path')
const webpack = require('webpack')
const glob = require("glob");
const VueLoaderPlugin = require('vue-loader/lib/plugin');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const WebpackAssetsManifest = require("webpack-assets-manifest");
const { CleanWebpackPlugin } = require('clean-webpack-plugin');
const FilterWarningsPlugin = require("webpack-filter-warnings-plugin");

const environment = process.env.NODE_ENV || 'development'
const isProd = environment === "production";
const packs = path.join(__dirname, 'app', 'javascript', 'packs');

const targets = glob.sync(path.join(packs, '**/*.{js,jsx,ts,tsx,vue}'),{
  ignore: ["**/hello_vue.js"],
})

const entries = targets.reduce((entries, target) => {
    const bundle = path.relative(packs, target)
    const ext = path.extname(bundle)
    return Object.assign({}, entries, {
      [bundle.replace(ext, '')]: './' + bundle,
    })
}, {})

let entries_admin = {};
let entries_basic = {};
let entries_app = {};

Object.keys(entries).forEach((key)=>{
  if (key === 'application_admin' || key === 'dash') {
    entries_admin[key] = entries[key];
  } else if (key === 'application' || key === 'login') {
    entries_basic[key] = entries[key];
  } else {
    entries_app[key] = entries[key];
  }
})

let set_base = {
    devtool: 'source-map',
    mode: environment,
    context: path.resolve(__dirname, 'app/javascript/packs'),
    entry: entries_basic,//entries,
    output: {
      filename: 'js/[name]-[contenthash].js',
      chunkFilename: 'js/[name]-[contenthash].chunk.js',
      hotUpdateChunkFilename: 'js/[id]-[contenthash].hot-update.js',
      path: path.resolve(__dirname, './public/packs'),
      publicPath: '/packs/',
      pathinfo: true
      
    },
    optimization: {
    },
    module: {
      rules: [
        {
          test: /\.vue$/,
          exclude: /node_modules/,
          loader: 'vue-loader',
        },
        {
          test: /\.(css|sass|scss)$/, 
          exclude: /node_modules/,
          use: [
            {
              loader: MiniCssExtractPlugin.loader,
              options: {
                publicPath: path.resolve(__dirname, 'public/packs/css')
              }
            },
            {
              loader: 'css-loader',
              options: {
                url: false
              },
            },
            // 'postcss-loader',
            {
              loader: 'sass-loader',
            }
          ]
        },
        {
          test: /\.(jpg|jpeg|png|gif|tiff|ico|svg|eot|otf|ttf|woff|woff2)$/i,
          exclude: /node_modules/,
          generator: {
            filename: '[name]-[contenthash][ext]',
            outputPath: function(path){
              const result = path.filename.match(/images\/(.+\/).+\./);
              return 'images/' + result[1];
            },
            publicPath: function(path){
              const result = path.filename.match(/images\/(.+\/).+\./);
              return '/packs/images/' + result[1];
            }
          },
          type: 'asset/resource'
        },
        {
          test: /\.(js|jsx|mjs)$/,
          // exclude: /node_modules/,
          include: /node_modules/,
          exclude: /(?:@?babel(?:\/|\/\/{1,2}|-).+)|regenerator-runtime|core-js|^webpack$|^webpack-assets-manifest$|^webpack-cli$|^webpack-sources$|^@rails\/\/webpacker$/,
          use: {
            loader: "babel-loader",
            options: {
              presets: [
                [
                  "@babel/preset-env",
                  {
                    modules: false
                  }
                ]
              ],
              // plugins: ["@babel/plugin-transform-runtime"],
              compact: false
            },
          },
        },
      ],
    },
    plugins: [
      new MiniCssExtractPlugin(
        {
          filename: 'css/[name]-[contenthash].css'
        }
      ),
      new WebpackAssetsManifest({
        publicPath: true,
        output: "manifest.json",
        writeToDisk: true,
      }),
      new FilterWarningsPlugin({
        exclude:
          /mini-css-extract-plugin[^]*Conflicting order. Following module has been added:/,
        })
    ],
    resolve: {
      extensions: [
        ".vue",
        ".mjs",
        ".js",
        ".sass",
        ".scss",
        ".css",
        ".module.sass",
        ".module.scss",
        ".module.css",
        ".png",
        ".svg",
        ".gif",
        ".jpeg",
        ".jpg"
      ],
      alias: { 
        // vue: 'vue/dist/vue.js' 
        vue$: 'vue/dist/vue.esm.js',
        '@images': path.resolve(__dirname, './app/javascript/images'),
        '@': path.resolve(__dirname, './app/javascript/packs'),
        '~': path.resolve(__dirname, './app/javascript'),
        jquery: path.join(__dirname, 'node_modules', 'jquery')
      },
      modules: [
        path.resolve(__dirname, "./app/javascript"),
        "node_modules"
      ]
    },
  }





let set_admin = {...set_base}
let set_app = {...set_base}
set_admin.entry = entries_admin
set_app.entry = entries_app

set_base.optimization = Object.assign({}, {
  splitChunks: {
    cacheGroups: {
      vendor: {
        test: /node_modules/,
        name: 'vendor',
        chunks: 'initial'
      }
    }
  }
});

set_admin.optimization = Object.assign({}, {
  splitChunks: {
    cacheGroups: {
      'vendorAdmin': {
        test: /node_modules/,
        name: 'vendor_admin',
        chunks: 'initial'
      }
    }
  }
});
set_app.optimization = Object.assign({}, {
  splitChunks: {
    cacheGroups: {
      'vendorApp': {
        test: /node_modules/,
        name: 'vendor_app',
        chunks: 'initial'
      }
    }
  }
});


set_admin.plugins = Object.assign([], [...set_admin.plugins, new webpack.ProvidePlugin({
  $: 'jquery',
  jQuery: "jquery",
  jquery: "jquery",
  "window.jQuery": 'jquery',
  Popper: 'popper.js'
})])
set_base.plugins = Object.assign([], [...set_base.plugins, new CleanWebpackPlugin(), new webpack.ProvidePlugin({
  $: 'jquery',
  jQuery: "jquery",
  jquery: "jquery",
  "window.jQuery": 'jquery',
  Popper: 'popper.js'
})])
set_app.plugins = Object.assign([],[...set_app.plugins, new VueLoaderPlugin()])

if (!isProd) {
  set_base.devServer = Object.assign({},{
      clientLogLevel: 'none',
      compress: true,
      host: 'localhost',
      port: 3035,
      publicPath: '/packs/',
      contentBase: path.resolve(__dirname, 'public/packs'),
      hot: true,
      useLocalIp: false,
      headers: {
        "Access-Control-Allow-Origin": "*",
      },
      watchOptions: {
        ignored: "**/node_modules/**"
      }
  })
}

const set_types = {
  base: set_base,
  admin: set_admin,
  app: set_app,
}
module.exports = (env, argv) => {
  const isProduction = argv.mode === 'production';
  return [
    set_base,
    set_app,
    set_admin
  ]
}