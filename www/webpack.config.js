var path = require('path');
var node_modules = path.resolve(__dirname, 'node_modules');

var config = {
    entry: path.resolve(__dirname, 'app/app.js'),
    resolve: {
        modulesDirectories: ["web_modules", "node_modules"], // same as default
        alias: {
        }
    },
    output: {
        path: path.resolve(__dirname, 'public'),
        filename: 'bundle.js'
    },
    module: {
        noParse: [ node_modules + "\/.*"],
        loaders: [
            { test: /\.js$/, loader: 'jsx-loader?harmony' },
            { test: /\.less$/, loader: 'style-loader!css-loader!less-loader' }, // use ! to chain loaders
            { test: /\.css$/, loader: 'style-loader!css-loader' },
            { test: /\.(png|jpg|woff|woff2|eot|ttf|svg)$/, loader: 'url-loader?limit=8192' } // inline base64 URLs for <=8k images, direct URLs for the rest
        ]
    }
};

module.exports = config;