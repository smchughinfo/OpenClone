const path = require('path');

module.exports = {
    devtool: 'eval-source-map', // todo: take out in production
    entry: {
        answer: './ClientApp/Pages/QA/Answer/Answer.jsx', 
        edit: './ClientApp/Pages/QA/Edit/Edit.jsx',
        chatbot: './ClientApp/Pages/ChatBot/ChatBot.jsx',
        settings: './ClientApp/Pages/Settings/Settings.jsx',
        clonecrud: './ClientApp/Pages/CloneCRUD/CloneCRUD.jsx',
    },
    output: {
        path: path.resolve(__dirname, 'wwwroot/dist'), // Output directory
        filename: '[name].bundle.js' // This will dynamically generate bundle names based on entry point keys
    },
    module: {
        rules: [
            {
                test: /\.(js|jsx)$/, // Match js and jsx files
                exclude: /node_modules/,
                use: {
                    loader: 'babel-loader',
                    options: {
                        presets: ['@babel/preset-env', '@babel/preset-react']
                    }
                }
            },
            {
                test: /\.css$/,
                use: [
                    'style-loader', // Injects CSS into the DOM via <style> tags
                    'css-loader', // Translates CSS into CommonJS
                ],
            },
        ]
    },
    resolve: {
        extensions: ['.js', '.jsx'], // Automatically resolve these file extensions
        alias: {
            js: path.resolve(__dirname, 'wwwroot/js'),
            css: path.resolve(__dirname, 'wwwroot/css'),
            jsx: path.resolve(__dirname, 'wwwroot/components'), // or jsx, if you prefer
        }
    }
};
