const express = require('express')
const ejs = require('ejs')

const PORT = process.env.PORT || 3000


const app = express()
app.set('views', 'views')
app.set('view engine', 'ejs')
app.use(express.static('public'))

app.locals.version = require('./package.json').version

// console.log(process.env.NODE_ENV)
if (process.env.NODE_ENV == 'development') {
  const livereload = require('connect-livereload')
  app.use(livereload())
}

app.get('/', (req, res) => {
  res.render('index', {})
})

app.listen(PORT, () => {
  console.log(`listening on port ${PORT}`)
})
