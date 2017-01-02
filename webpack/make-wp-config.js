var path = require('path');
var webpack = require('webpack');
var merge = require('webpack-merge');
var ProgressBarPlugin = require('progress-bar-webpack-plugin');
var babelMerge = require('./babel-merge');
var ExtractTextPlugin = require("extract-text-webpack-plugin"); //单独打包css
var HtmlWebpackPlugin = require("html-webpack-plugin");//html模板生成插件

//输出HTML和CSS等等文件到路径的插件
var CopyWebpackPlugin = require('copy-webpack-plugin');

module.exports = function(options) {
    var dir = options.dir || __dirname, //根目录
        mainFile = options.mainFile, //程序入口主文件
        outputPath = options.outputPath, //编译输出文件目录
        needbabelPath = options.needbabelPath || "./", //需babel的目录
        outputPublicPath = options.outputPublicPath, //服务路径,用于热替换服务器
        mode = options.mode || process.env.NODE_ENV || 'development', //编译模式
        host = options.host || "localhost",
        port = options.port,
        vendor = options.vendor || [],
        htmlTemplet = options.htmlTemplet || {}, //html模板配置
        baseUrl = 'http://' + host + ':' + port;

    if (mode === 'development') mode = 'development';
    if (mode === 'production') mode = 'production';

    ////////////////////////////////////////////////////////////////////////////////
    // BASE
    ////////////////////////////////////////////////////////////////////////////////

    var babelQueryBase = {
        presets: ["es2015", "react","stage-0"],
        //plugins: ["transform-decorators-legacy"], //ES7的方法Decorator的转码器
        cacheDirectory: true 
    };

    var config = {
        context: dir,
        entry: [],
        output: {
            path: outputPath,
            publicPath: outputPublicPath,
            pathinfo: true,
            chunkFilename: "[name].chunk.js", //公用文件打包文件
            filename: "[name].js"      //根据入口文件输出的对应多个文件名
        },
        resolve: {
            root: path.resolve('src'),
            //modulesDirectories: ['node_modules'],//只有在有很复杂的路径下，才考虑使用 moduledirectories
            extensions: ['', '.js', '.jsx', '.json', '.es6'],
            //root: path.join(__dirname, '../app')
            //配置别名，在项目中可缩减引用路径
            alias: {
                //'weui': path.resolve(dir, "/node_modules/weui/dist/weui.min.css")
                //moment: "moment/min/moment-with-locales.min.js"
            }
        },
        module: {
            //各种加载器，即让各种文件格式可用require引用
            loaders: [
                //使用babel-loader来解析js,es6文件
                {
                    test: /\.(js|es6|jsx)$/,
                    //test: /\.js$/,
                    loader: ['babel-loader'],
                    //指定作用范围,这里可不写,但是范围越小速度越快
                    include: path.resolve(dir, needbabelPath),
                    //排除目录,exclude后将不匹配
                    exclude: /node_modules/,
                    query: babelQueryBase
                },
                //.scss 文件使用 style-loader、css-loader 和 sass-loader 来编译处理
                //对于css文件，默认情况下webpack会把css content内嵌到js里边，运行时会使用style标签内联
                { test: /\.(less|css)$/, loader: 'style!css!less' },
                //图片文件使用 url-loader 来处理，小于8kb的直接转为base64
                //{ test: /\.(png|jpg)$/, loader: 'url-loader?limit=8192'},
                //图片资源在加载时先压缩，然后当内容size小于~10KB时，会自动转成base64的方式内嵌进去
                //当图片大于10KB时，则会在img/下生成压缩后的图片，命名是[hash:8].[name].[ext]的形式
                //hash:8的意思是取图片内容hushsum值的前8位，这样做能够保证引用的是图片资源的最新修改版本，保证浏览器端能够即时更新
                {
                    test: /\.(jpe?g|png|gif|svg)$/i,
                    loaders: [
                        'image?{bypassOnDebug: true, progressive:true, optimizationLevel: 3, pngquant:{quality: "65-80"}}',
                        'url?limit=2000&name=img/[hash:8].[name].[ext]'
                    ]
                },
                {
                    test: /\.(woff|eot|ttf)$/i,
                    loader: 'url?limit=10000&name=fonts/[hash:8].[name].[ext]'
                }
            ]
        },
        plugins: [
            new ProgressBarPlugin(),
            //预加载的插件
            new webpack.PrefetchPlugin("react"),
          //  new webpack.PrefetchPlugin("react/lib/ReactComponentBrowserEnvironment")
        ]
    };

    //////////////////////////////////////////////////////////////////////////////////
    ////  DEVELOPMENT
    //////////////////////////////////////////////////////////////////////////////////
    //
    if (mode === 'development') {
        config = merge.smart(config, {
            // 生成sourcemap,便于开发调试,正式打包请去掉此行或改成none
            devtool: "eval",// eval生成 sourcemap 的不同方式
            //入口文件,需要处理的文件路径
            entry: [
                'babel-polyfill',
                'webpack/hot/dev-server',
                'webpack-dev-server/client?'+baseUrl,
                //上面2个是开发的时候用的热替换服务器
                path.resolve(dir, mainFile)
            ],
            module: {
                //各种加载器，即让各种文件格式可用require引用
                loaders: [
                    //使用babel-loader来解析js,es6,jsx文件
                    {
                        test: /\.js$/,
                        //loaders: ['react-hot', 'babel-loader'],
                        loaders: ['react-hot', 'babel-loader'],
                        loader: 'babel',
                        //include: path.resolve(dir, needbabelPath),
                        exclude: /node_modules/,
                        query: babelMerge(babelQueryBase, {
                            "plugins": [
                                ["react-transform", {
                                    "transforms": [
                                        {
                                            "transform": "react-transform-hmr",
                                            "imports": ["react"],
                                            "locals": ["module"]
                                        },
                                        {
                                            "transform": "react-transform-catch-errors",
                                            "imports": ["react", "redbox-react"]
                                        }
                                    ]
                                }]
                            ]
                        })

                    }
                ]
            },
            plugins: [
                //热替换插件
                new webpack.HotModuleReplacementPlugin(),
                //允许错误不打断程序
                new webpack.NoErrorsPlugin(),
                new webpack.DefinePlugin({//设置环境
                    "process.env": {
                        NODE_ENV: JSON.stringify("development")
                    }
                })
            ]
        })
    }

    ////////////////////////////////////////////////////////////////////////////////
    //  PRODUCTION
    ////////////////////////////////////////////////////////////////////////////////

    if (mode === 'production') {
        config = merge.smart(config, {
            entry: {
                //"js/babelPolyfill": 'babel-polyfill',
                "js/app": path.join(dir, 'src/js/app.js'),
                "js/vendor" : vendor // 第三方库包
            },
            module: {
                loaders: [
                    {
                        test: /\.(js|es6|jsx)$/,
                        loader: 'babel',
                        exclude: /node_modules/,
                        query: babelMerge(babelQueryBase)
                    },
                    {//单独打包css文件
                        test: /\.(less|css)$/,
                        loader:  ExtractTextPlugin.extract('style', 'css!autoprefixer!less')
                    }
                ],
                //noParse: ["react"]
            },
            resolve: {
                alias: {//重定向
                    //react: "react/dist/react.min.js",
                    //moment: "moment/min/moment-with-locales.min.js"
                }
            },
            //声明一个外部依赖,该文件不会打包进去,但是要在html页面引入
            externals: {
                //'react': 'React',
                //"react-dom": "ReactDOM",
                ////'react-addons-css-transition-group': "ReactCSSTransitionGroup",
                //"react-router": "ReactRouter",
                //'redux': 'Redux',
                //'react-router-redux': 'ReactRouterRedux'
            },
            autoprefixer: { //浏览器兼容前缀
                browsers: ['last 2 version', 'opera 12.1', 'ios 6', 'android 4']
            },
            plugins: [
                //js文件的压缩
                new webpack.optimize.UglifyJsPlugin({
                    compressor: {
                        warnings: false
                    },
                    output: {
                        comments: false,
                    },
                    //except: ['$super', '$', 'exports', 'require']    //排除关键字
                }),
                //将公共代码抽离出来合并为一个文件
                new webpack.optimize.CommonsChunkPlugin({
                    name:"js/vendor",
                    filename:"js/base.js",
                    minChunks:3 //// 提取至少3个模块共有的部分
                }),
                //单独打包css
                new ExtractTextPlugin("css/common.css"),
                //HtmlWebpackPlugin，模板生成相关的配置，每个对于一个页面的配置，有几个写几个
                new HtmlWebpackPlugin(htmlTemplet),
                //减小打包文件大小
                //new webpack.DefinePlugin({//设置环境
                //    "process.env": {
                //        NODE_ENV: JSON.stringify("production")
                //    }
                //})
                new webpack.DefinePlugin({
                    'process.env.NODE_ENV': '"production"'
                }),
                //new webpack.DllReferencePlugin({
                //    context: dir,
                //    manifest: require('./manifest.json'),
                //}),
            ]
        });
    }

    return config;

};
