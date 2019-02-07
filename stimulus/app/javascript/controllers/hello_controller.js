// Visit The Stimulus Handbook for more details 
// https://stimulusjs.org/handbook/introduction
// 
// This example controller works with specially annotated HTML like:
//
// <div data-controller="hello">
//   <h1 data-target="hello.output"></h1>
// </div>

import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "name", "output", "content", "preview"]

  connect() {
    this.outputTarget.textContent = 'Hello, Stimulus!'
  }

  greet() {
    const element = this.nameTarget
    const name = element.value
    alert(`Hello, ${name}! Welcome to Stimulus!`)
  }

  puts() {
    this.previewTarget.textContent = this.contentTarget.value
  }
}
