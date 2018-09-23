const express = require('express')
const path = require('path')
const port = process.env.PORT || 3000
const app = express()

app.use(express.static('./public'))

app.get('/', (req, res, next) => {
  res.send(path.join(__dirname + '/index.html'))
}).listen(port)
console.log('Server running at http://127.0.0.1:' + port + '/')
