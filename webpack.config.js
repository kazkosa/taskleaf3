const path = require('path')
const webpack = require('webpack')
const glob = require("glob");
const VueLoaderPlugin = require('vue-loader/lib/plugin');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
// const { WebpackManifestPlugin } = require('webpack-manifest-plugin');
const WebpackAssetsManifest = require("webpack-assets-manifest");
const { CleanWebpackPlugin } = require('clean-webpack-plugin');

const environment = process.env.NODE_ENV || 'development'
// const { NODE_ENV } = process.env;
const isProd = environment === "production";
const packs = path.join(__dirname, 'app', 'javascript', 'packs');

const targets = glob.sync(path.join(packs, '**/*.{js,jsx,ts,tsx,vue}'),{
  ignore: ["**/hello_vue.js"],
})

let tmp_list = []
const entries = targets.reduce((entries, target) => {
    const bundle = path.relative(packs, target)
    const ext = path.extname(bundle)
    return Object.assign({}, entries, {
      // Input: "application.js"
      // Output: { "application": "./application.js" }
      [bundle.replace(ext, '')]: './' + bundle,
    })
}, {})
module.exports = (env, argv) => {
  const isProduction = argv.mode === 'production';
  return {
    devtool: "eval-source-map",
    mode: environment,
    context: path.resolve(__dirname, 'app/javascript/packs'),
    entry: entries,
    // entry: {
    //   application: './application.js',
    // },
    output: {
      // filename: isProd ? 'js/[name]-[contenthash].js' : 'js/[name]-[contenthash].js',
      filename: 'js/[name]-[contenthash].js',
      path: path.resolve(__dirname, './public/packs'),
      // assetModuleFilename: 'images/[path][name]-[contenthash].[ext]',
      publicPath: '/packs/',
    },
    module: {
      rules: [
        {
          test: /\.(css|sass|scss)$/, 
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
          test: /\.vue$/,
          exclude: /node_modules/,
          loader: 'vue-loader',
          options: {
            extractCSS: true,
          }
        },
        {
          test: /\.js$/,
          exclude: /node_modules/,
          use: {
            loader: "babel-loader",
            options: {
              presets: ["@babel/preset-env"],
              plugins: ["@babel/plugin-transform-runtime"],
            },
          },
        },
      ],
    },
    plugins: [
      new CleanWebpackPlugin(),
      new VueLoaderPlugin(),
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
      new webpack.ProvidePlugin({
        $: 'jquery',
        jQuery: "jquery",
        jquery: "jquery",
        "window.jQuery": 'jquery',
        Popper: 'popper.js'
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
        // vue$: 'vue/dist/vue.esm.js',
        '@images': path.resolve(__dirname, './app/javascript/images'),
        '@': path.resolve(__dirname, './app/javascript/packs'),
        '~': path.resolve(__dirname, './app/javascript'),
        jquery: path.join(__dirname, 'node_modules', 'jquery')
      },
      // modules: [
      //   path.resolve(__dirname, "./app/javascript"),
      //   "node_modules"
      // ]
    },
    devServer: {
      host: 'localhost',
      port: 3035,
      publicPath: '/packs/',
      contentBase: path.resolve(__dirname, 'public/packs'),
      hot: true,
      headers: {
        "Access-Control-Allow-Origin": "*",
      },
    },
  };
}