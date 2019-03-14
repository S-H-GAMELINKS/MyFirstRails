import { Elm } from '../Index'

document.addEventListener('DOMContentLoaded', () => {
  const target = document.createElement('div')

  document.body.appendChild(target)
  Elm.Index.init({
    node: target
  })
})