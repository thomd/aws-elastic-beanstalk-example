#!/usr/bin/env bash

mkdir -p vanilla-website/{public/assets/{images,scripts,styles},src/{scripts,styles}}
cd vanilla-website

cat <<EOF > .babelrc
{
  "presets": [
    [
      "@babel/preset-env",
      {
        "targets": {
          "browsers": ["> 1%"]
        }
      }
    ]
  ]
}
EOF

cat <<EOF > postcss.config.js
const postcssPresetEnv = require('postcss-preset-env');
if (process.env.NODE_ENV === 'production') {
  module.exports = {
    plugins: [
      postcssPresetEnv({
        browsers: ['> 1%']
      }),
      require('cssnano')
    ]
  };
  return;
}
module.exports = {};
EOF

cat <<EOF > webpack.config.js
const path = require('path');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const devMode = process.env.NODE_ENV !== 'production';

module.exports = {
  mode: devMode ? 'development' : 'production',
  entry: ['./src/scripts/main.js', './src/styles/main.scss'],
  output: {
    path: path.resolve(__dirname, 'public'),
    publicPath: '/assets',
    filename: 'assets/scripts/bundle.js'
  },
  module: {
    rules: [
      {
        test: /\.(js)$/,
        exclude: /node_modules/,
        use: ['babel-loader']
      },
      {
        test: /\.(sa|sc)ss$/,
        use: [
          {
            loader: MiniCssExtractPlugin.loader
          },
          {
            loader: 'css-loader',
            options: {
              importLoaders: 2
            }
          },
          {
            loader: 'postcss-loader'
          },
          {
            loader: 'sass-loader'
          }
        ]
      },
      {
        test: /\.(png|jpe?g|gif)$/,
        use: [
          {
            loader: 'file-loader',
            options: {
              name: '[name].[ext]',
              publicPath: '../images',
              emitFile: false
            }
          }
        ]
      }
    ]
  },
  plugins: [
    new MiniCssExtractPlugin({
      filename: 'assets/styles/main.css'
    })
  ]
};
EOF

cat <<EOF > public/index.html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta http-equiv="X-UA-Compatible" content="ie=edge">
  <title>No Framework Website</title>
<link rel="stylesheet" href="./assets/styles/main.css">
</head>
<body>
  <div class="wrapper">
    <header>
      <h1>No Framework Website</h1>
    </header>
    <main>
      <h2>This site rocks</h2>
      <div class="bacon">
        <img src="./assets/images/oval.svg" alt="loading">
      </div>
    </main>
    <footer>
      <p>Made with love by thomd</p>
    </footer>
  </div>
  <script src="./assets/scripts/bundle.js"></script>
</body>
</html>
EOF

cat <<EOF > src/styles/reset.scss
html {
  height: 100%;
  box-sizing: border-box;
  font-size: 100%;
}

*,*:before,*:after { box-sizing: inherit; }

body {
  margin: 0;
  padding: 0;
  height: 100%;
  overflow-x: hidden;
  font-family: Helvetica, Arial, sans-serif;
  color: #3b3b3b;
}

h1,h2,h3,h4,h5 {
  margin: 6px;
  padding: 0;
}
EOF

cat <<EOF > src/styles/main.scss
@import 'reset.scss';

.wrapper {
  min-height: 100vh;
  display: grid;
  grid-template-columns: 1fr 2fr 1fr;
  grid-template-rows: auto 1fr auto;
  line-height: 23px;

  & > * { grid-column: 2 / -2; }

  header {
    grid-column: 1 / -1;
    width: 100vw;
    height: 100vh;
    background: linear-gradient(red, transparent), linear-gradient(to top left, lime, transparent), linear-gradient(to top right, blue, transparent);
    background-blend-mode: screen;
    background-size: cover;
    height: 500px;
    margin-bottom: 20px;
    display: flex;
    justify-content: center;
    align-items: center;
    color: #fff;
    text-align: center;

  h1 {
      font-size: 3.5em;
      text-shadow: -2px -2px 3px rgb(163, 162, 162);
    }
  }

  h2 {
    margin: 0;
  }

  footer {
    height: 50px;
    display: flex;
    justify-content: flex-end;
  }
}

.bacon > img {
  width: 75px;
  display: block;
  margin: auto;
}
EOF

cat <<EOF > src/scripts/utils.js
export const GetBacon = () => {
  const body = fetch('https://baconipsum.com/api/?type=all-meat&paras=3').then( res => res.json() );
  return body;
};
EOF

cat <<EOF > src/scripts/main.js
import { GetBacon } from './utils';
const baconEl = document.querySelector('.bacon');
GetBacon()
  .then(res => {
    const markup = res.reduce((acc, val) => (acc += \`<p>\${val}</p>\`), '');
    baconEl.innerHTML = markup;
  }).catch(err => (baconEl.innerHTML = err));
EOF

cat <<EOF > public/assets/images/oval.svg
<svg width="38" height="38" viewBox="0 0 38 38" xmlns="http://www.w3.org/2000/svg" stroke="#231F1F">
    <g fill="none" fill-rule="evenodd">
        <g transform="translate(1 1)" stroke-width="2">
            <circle stroke-opacity=".5" cx="18" cy="18" r="18"/>
            <path d="M36 18c0-9.94-8.06-18-18-18">
                <animateTransform
                    attributeName="transform"
                    type="rotate"
                    from="0 18 18"
                    to="360 18 18"
                    dur="1s"
                    repeatCount="indefinite"/>
            </path>
        </g>
    </g>
</svg>
EOF

cp ../venice-italy.jpg public/assets/images/

npm init -y
touch .babelrc postcss.config.js webpack.config.js public/index.html src/{scripts/{main.js,utils.js},styles/{main.scss,reset.scss}}
npm i -D @babel/core babel-loader @babel/preset-env cross-env css-loader cssnano file-loader live-server
npm i -D mini-css-extract-plugin node-sass npm-run-all postcss-loader postcss-preset-env sass-loader webpack
npm i -D webpack-cli npm-scripter
./node_modules/.bin/npm-scripter dev:assets "webpack --watch"
./node_modules/.bin/npm-scripter dev:start "live-server --open=./public/ --host=localhost --watch=./public/"
./node_modules/.bin/npm-scripter dev "npm-run-all -p dev:*"
./node_modules/.bin/npm-scripter build "cross-env NODE_ENV=production webpack"
./node_modules/.bin/npm-scripter -d test
