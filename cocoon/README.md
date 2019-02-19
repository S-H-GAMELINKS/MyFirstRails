# Coccoonでの動的なネストフォーム
## 概要

Railsにこれから初めて触れる方を対象にしたチュートリアルです
今回は、[`Coccoon`](https://github.com/nathanvda/cocoon)でのネストされた動的なフォームを実装します

## チュートリアル
### Railsのひな型を作る

まず、`rails new`を実行し、Railsアプリのひな型を作成します

```shell
rails new coccoon
```

次に、作成した`coccoon`ディレクトリへと移動します

```shell
cd coccoon
```

### SQLite3のバージョンを修正

先ほどの`rails new`で`sqlite3`のインストールがエラーになっている場合は、以下のようにバージョンを指定してください

```ruby:Gemfile
gem 'sqlite3', '1.3.13'
```

その後、`bundle install`を実行します

```shell
bundle install
```

### ScaffoldでCRUDを作成

`rails g scaffold`コマンドを使い、ひな型を作成します

```shell
rails g scaffold project title:string
```

その後、マイグレーションを実行します

```shell
rails db:migrate
```

これでひな型の`Project`を作成できました！

### root pathの追加

`config/routes.rb`を以下のように変更し、`root path`を追加します

```ruby:config/routes.rb
Rails.application.routes.draw do
  root 'projects#index'
  resources :projects
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
```

これでOKです！

### Coccoonのインストール

まず、`Gemfile`に`gem 'coccoon'`と`gem 'jquery-rails'`を追加します

```ruby:Gemfile
gem 'coccoon'
gem 'jquery-rails'
```

次に、`app/assets/javascripts/application.js`に`//= require cocoon`と`//= require jquery`を追加します

```js:app/assets/javascripts/application.js
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
//= require turbolinks
//= require jquery
//= require cocoon
//= require_tree .
```

その後、ネストする子側の`Task`モデルを作成します

```shell
rails g model Task description:string done:boolean project:belongs_to
```

モデル作成後に、`rails db:migrate`を実行します

```shell
rails db:migrate
```

`Project`モデルに`Task`モデルへのリレーションシップを追加します

```ruby:app/models/project.rb
class Project < ApplicationRecord
    has_many :tasks, inverse_of: :project
    accepts_nested_attributes_for :tasks, reject_if: :all_blank, allow_destroy: true
end
```

`app/controllers/projects_controller.rb`、`app/views/projects/_form.html.erb`、`app/views/projects/show.html.erb`を以下のように変更します

```ruby:app/controllers/projects_controller.rb
class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy]

  # GET /projects
  # GET /projects.json
  def index
    @projects = Project.all
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
    @tasks = Task.find(@project.task_ids)
  end

  # GET /projects/new
  def new
    @project = Project.new
    @tasks = @project.tasks.build
  end

  # GET /projects/1/edit
  def edit
  end

  # POST /projects
  # POST /projects.json
  def create
    @project = Project.new(project_params)

    respond_to do |format|
      if @project.save
        format.html { redirect_to @project, notice: 'Project was successfully created.' }
        format.json { render :show, status: :created, location: @project }
      else
        format.html { render :new }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /projects/1
  # PATCH/PUT /projects/1.json
  def update
    respond_to do |format|
      if @project.update(project_params)
        format.html { redirect_to @project, notice: 'Project was successfully updated.' }
        format.json { render :show, status: :ok, location: @project }
      else
        format.html { render :edit }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    @project.destroy
    respond_to do |format|
      format.html { redirect_to projects_url, notice: 'Project was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def project_params
      params.require(:project).permit(:title, tasks_attributes: [:id, :description, :done, :_destroy])
    end
end
```

```erb:app/views/projects/_form.html.erb
<%= form_with(model: project, local: true) do |form| %>
  <% if project.errors.any? %>
    <div id="error_explanation">
      <h2><%= pluralize(project.errors.count, "error") %> prohibited this project from being saved:</h2>

      <ul>
      <% project.errors.full_messages.each do |message| %>
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
        <h2>Tasks</h2>
        <div id="tasks">
          <%= form.fields_for :tasks do |task| %>
            <%= render 'task_fields', f: task %>
          <% end %>
        </div>
        <div class="links">
          <%= link_to_add_association 'add task', form, :tasks %>
        </div>
  </div>

  <div class="actions">
    <%= form.submit %>
  </div>
<% end %>
```

```erb:app/views/projects/show.html.erb
<p id="notice"><%= notice %></p>

<p>
  <strong>Title:</strong>
  <%= @project.title %>
</p>

<% @tasks.each do |task| %>
  <p><%= task.description %></p>
<% end %>

<%= link_to 'Edit', edit_project_path(@project) %> |
<%= link_to 'Back', projects_path %>
```

最後に、`app/views/projects/_task_fields.html.erb`を作成します

```erb:app/views/projects/_task_fields.html.erb
<div class="nested-fields well well-compact">
  <div class="form-group">
    <%= f.text_field :description %>
    <%= f.check_box :done, as: :boolean %>
    <%= link_to_remove_association "remove task", f %>
  </div>
</div>
```

あとは、`rails s`でローカルサーバを起動します
あとは`localhost:3000/projects/new`でフォームの追加や削除ができるようになっていると思います

これで`Coccoon`でのネストされたフォームは実装完了です
