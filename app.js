const express = require('express')
const path = require('path')

const app = express()

app.use(express.static('./public'))

app.get('/', (req, res, next) => {
  res.send(path.join(__dirname + '/index.html'))
}).listen(3000)
