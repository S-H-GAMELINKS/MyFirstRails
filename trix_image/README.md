# Trixでの画像アップロード機能実装
## 概要

Railsにこれから初めて触れる方を対象にしたチュートリアルです

[`Trix`](https://github.com/basecamp/trix)に画像アップロード機能を作るチュートリアルになります

## チュートリアル
### Railsのひな型を作る

まず、`rails new`を実行し、Railsアプリのひな型を作成します

```shell
rails new trix_image
```

次に、作成したRailsアプリのディレクトリへと移動します

```shell
cd trix_image
```

### SQLite3のバージョンを修正

先ほどの`rails new`で`sqlite3`のインストールがエラーになっている場合は、以下のようにバージョンを修正します

```ruby:Gemfile
gem 'sqlite3', '1.3.13'
```

その後、`bundle install`を実行します

```shell
bundle install
```

### ScaffoldでCRUDを作成

`rails g scaffold` コマンドを使い、`Trix`で使用するCRUDを作成します

```shell
rails g scaffold post title:string content:text auther:string
```

次に、画像投稿用のCRUDを作成します

```shell
rails g scaffold photo image
```

その後、`rails db:migrate`でマイグレーションを行います

```shell
rails db:migrate
```

### Trixの導入

`Trix`を導入していきます

まずは`Gemfile`に`Trix`を追加します

```ruby:Gemfile
gem 'trix'
```

その後、`bundle install`を実行します

```shell
bundle install
```

次に、`app/assets/javascripts/application.js`に以下の行を追加します

```js:app/assets/javascripts/application.js
//= require trix
```

また、`app/assets/stylesheets/application.css`にも以下の行を追加します

```css:app/assets/stylesheets/application.css
*= require trix
```

`app/views/posts/_form.html.erb`を以下のように変更します

```erb:app/views/posts/_form.html.erb
<%= form_with(model: post, local: true) do |form| %>
  <% if post.errors.any? %>
    <div id="error_explanation">
      <h2><%= pluralize(post.errors.count, "error") %> prohibited this post from being saved:</h2>

      <ul>
      <% post.errors.full_messages.each do |message| %>
        <li><%= message %></li>
      <% end %>
      </ul>
    </div>
  <% end %>

  <div class="field">
    <%= form.label :title %>
    <%= form.text_field :title %>
  </div>

  <div class="field">
    <%= form.label :content %>
    <%= form.hidden_field :content, id: 'post_content' %>
    <trix-editor input="post_content"></trix-editor>
  </div>

  <div class="actions">
    <%= form.submit %>
  </div>
<% end %>
```

最後に、`app/view/posts/show.html.erb`を以下のように変更します

```erb:app/view/posts/show.html.erb
<p id="notice"><%= notice %></p>

<p>
  <strong>Title:</strong>
  <%= @post.title %>
</p>

<p>
  <strong>Content:</strong>
  <%= sanitize @post.content %>
</p>

<%= link_to 'Edit', edit_post_path(@post) %> |
<%= link_to 'Back', posts_path %>
```

### Shrineでの画像アップロード

[`Shrine`](https://github.com/shrinerb/shrine)というアップロード用のgemを使用し、画像アップロード機能のひな型を作成します

まず、`Gemfile`に`Shrine`を追加します

```shell
gem 'shrine'
```

その後、`bundle install`を実行します

```shell
bundle install
```

その後、`config/initializers/shrine.rb`を以下のように作成します

```ruby:config/initializers/shrine.rb
require "shrine"
require "shrine/storage/file_system"

Shrine.storages = {
  cache: Shrine::Storage::FileSystem.new("public", prefix: "uploads/cache"),
  store: Shrine::Storage::FileSystem.new("public", prefix: "uploads/store"),
}

Shrine.plugin :activerecord
Shrine.plugin :cached_attachment_data
```

次に、`app/views/photos/_photo.json.jbuilder`に以下の一行を追加します

```json:app/views/photos/_photo.json.jbuilder
json.image_url photo.image_url 
```

アップロード用のモデル`app/models/image_uploader.rb`を作成します

```ruby:app/models/image_uploader.rb
class ImageUploader < Shrine
end
```

作成したモデルを`Post`モデルに`include`します

```ruby:app/models/photo.rb
class Photo < ApplicationRecord
    include ImageUploader[:image]
end
```

`rails g migration`コマンドを使用して既存の`image`カラムを`image_data`カラムにリネームします

```shell
rails g migration RenameImageColumnToPhotos
```

作成したマイグレーションファイルを以下のようにします

```ruby:db/migrate/xxxxxxxxxxxxxx_rename_image_column_to_photos.rb
class RenameImageColumnToPhotos < ActiveRecord::Migration[5.2]
  def change
    rename_column :photos, :image, :image_data
  end
end
```

`rails db:migrate`を実行し、マイグレーションを行います

```shell
rails db:migrate
```

後は、`app/views/photos/_form.html.erb`を編集し、アップロードができるようにします

```erb:app/views/photos/_form.html.erb
<%= form_with(model: photo, local: true) do |form| %>
  <% if photo.errors.any? %>
    <div id="error_explanation">
      <h2><%= pluralize(photo.errors.count, "error") %> prohibited this photo from being saved:</h2>

      <ul>
      <% photo.errors.full_messages.each do |message| %>
        <li><%= message %></li>
      <% end %>
      </ul>
    </div>
  <% end %>

  <div class="field">
    <%= form.label :image %>
    <%= form.file_field :image, id: :photo_image %>
  </div>

  <div class="actions">
    <%= form.submit %>
  </div>
<% end %>
```

これで、画像のアップロードが実行できるようになりました

### Trixに画像をアップロード

`app/assets/javascripts/application.js`を以下のように修正します

```js:app/assets/javascripts/application.js
  
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
```

これで、エディターに画像をペーストするだけで画像のアップロードができるようになります！