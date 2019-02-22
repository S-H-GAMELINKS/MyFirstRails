const { environment } = require('@rails/webpacker')
const vue =  require('./loaders/vue')

environment.loaders.append('css', {
    test: /\.css$/,
    use: [
        'style-loader',
        'css-loader'
    ]
})

environment.loaders.append('vue', vue)
module.exports = environment
