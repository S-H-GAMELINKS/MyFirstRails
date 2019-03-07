# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'turbolinks:load', ->
  if !($('#editor').length) then return false
  editor = ace.edit('editor')
  textarea = $('#ruby_code').hide()
  editor.setTheme('ace/theme/monokai')
  editor.getSession().setMode('ace/mode/ruby')
  editor.getSession().setValue(textarea.val())
  editor.getSession().on('change', -> 
    textarea.val(editor.getSession().getValue()))