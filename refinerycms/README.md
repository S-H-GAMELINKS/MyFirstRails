# Refinery CMS サンプル
## 概要

Railsにこれから初めて触れる方を対象にしたチュートリアルです
[`Refinery CMS`]()というRailsで使用できるCMSをインストールするチュートリアルです

## チュートリアル
### Refinery CMSのテンプレートでひな型を作る

まず、`rails new`を実行し、ひな型を作成します

```shell
rails _5.1.6_ new refinerycms -m https://www.refinerycms.com/t/4.0.0
```

`_5.1.6_`は使用するRailsのバージョンを指定しています
`Refinery CMS`ではRalsのバージョンが`5.1`以上`5.2`以下である必要があります

なお、最新の`5.2.2`を使用すると`bundle install`の段階で`gem`がインストールできません

### サイトのタイトル変更

`config/initializers/refinery/core.rb`の`# config.site_name = "Company Name"`を修正します

```ruby:config/initializers/refinery/core.rb
config.site_name = "Refinery CMS"
```

これでサイトのタイトルが`Refinery CMS`に変更されています

### Refinery CMSの日本語化

`Refinery CMS`は初期状態では英語表記になっています
これを日本語に変更するには`config/initializers/refinery/i18n.rb`を以下のように修正します

```ruby:config/initializers/refinery/i18n.rb
Refinery::I18n.configure do |config|
  config.default_locale = :ja

  config.current_locale = :ja

  config.default_frontend_locale = :ja

  config.frontend_locales = [:ja]

  # config.locales = {:en=>"English", :fr=>"Français", :nl=>"Nederlands", :pt=>"Português", :"pt-BR"=>"Português brasileiro", :da=>"Dansk", :nb=>"Norsk Bokmål", :sl=>"Slovenian", :es=>"Español", :ca=>"Català", :it=>"Italiano", :de=>"Deutsch", :lv=>"Latviski", :ru=>"Русский", :sv=>"Svenska", :pl=>"Polski", :"zh-CN"=>"简体中文", :"zh-TW"=>"繁體中文", :el=>"Ελληνικά", :rs=>"Srpski", :cs=>"Česky", :sk=>"Slovenský", :ja=>"日本語", :bg=>"Български", :hu=>"Hungarian", :uk=>"Українська"}
end
```

これで日本語表記に変更されています！

### Refinery CMSの起動

作成した、`refinerycms`に移動し、`bundle exec rails s`でローカルサーバを起動します

```shell
cd refinerycms
bundle exec rails s
```

これで`localhost:3000`にアクセスするとホーム画面が表示されます

次に、新しいページなどを追加してみましょう
`localhost:3000/refinery`にアクセスすると初期ユーザーの登録画面にリダイレクトされます

名前やメールアドレスなどを入力後、`sign up`をクリックしてアカウントを作成します

アカウント作成後、管理画面に移動します

左のメニュー欄から「ページ」をクリックし、「Home」右横の`+`を選択し、子のページを作成します

タイトルとコンテンツを記入後、「保存」をクリックして変更を保存します

`localhost:3000`にアクセスすると`Home`以下に先ほど作成したページが追加されています
このように新しいページを追加していきます！