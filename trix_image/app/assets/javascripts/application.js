// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require activestorage
//= require trix
//= require turbolinks
//= require_tree .
  
   function uploadAttachment(attachment) {

    var file = attachment.file;
    var form = new FormData;
    form.append("Content-Type", file.type);
    form.append("photo[image]", file);
  
    var xhr = new XMLHttpRequest;
    xhr.open("POST", "/photos.json", true);
    xhr.setRequestHeader("X-CSRF-Token", Rails.csrfToken());
  
    xhr.upload.onprogress = function(event) {
      var progress = event.loaded / event.total * 100;
      attachment.setUploadProgress(progress);
    }
  
    xhr.onload = function() {
      if (xhr.status === 201) {
        var data = JSON.parse(xhr.responseText);
        return attachment.setAttributes({
          url: data.image_url,
          href: data.url
        })
      }
    }
  
     return xhr.send(form);
  }
  
   // Listen for the Trix attachment event to trigger upload
  document.addEventListener("trix-attachment-add", function(event) {
    var attachment = event.attachment;
    if (attachment.file) {
      return uploadAttachment(attachment);
    }
  });