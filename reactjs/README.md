# React.jsの導入
## 概要

Railsにこれから初めて触れる方を対象にしたチュートリアルです

RailsとReact.jsを使ってサンプルアプリを作成します

## チュートリアル
### Railsのひな型を作る

まず、`rails new`を実行し、Railsアプリのひな型を作成します。

```shell
rails new reactjs --webpack=react
```

`--webpack`はRailsで`Weboack`を使いやすくした[`Webpacker`](https://github.com/rails/webpacker)というものを使用するというオプションです

Vue、React、Angular、Elm、Stimulusを使用することができます

今回はReact.jsを使用するので`--webpack=react`としています

次に、作成したRailsアプリのディレクトリへと移動します。

```shell
cd reactjs
```

### Foremanを使う

[`Webpacker`](https://github.com/rails/webpacker)を使う場合、`ruby ./bin/webpack-dev-server`というコマンドを実行しつつ、`rails s`でローカルサーバーを起動する必要があります

その為、現状のままではターミナルを複数開いておく必要があり、少々面倒です

そこで、複数のコマンドを並列して実行できる[`foreman`](https://github.com/ddollar/foreman)を使用します

まず、`Gemfile`に`gem 'foreman'`を追記します

```ruby:Gemfile
gem 'foreman'
```

その後、`bundle install`

```shell
bundle install
```

この時、sqlite3がインストールできないエラーが発生するかもしれません その場合は以下のようにsqlite3のバージョンを修正して`bundle install`を実行してください

```ruby:Gemfile
gem 'sqlite3', '1.3.13'
```

```shell
bundle install
```

次に、`foreman`で使用する`Procfile.dev`を作成します

```Procfile.dev
web: bundle exec rails s
webpacker: ruby ./bin/webpack-dev-server
```

あとは、`foreman start -f Procfile.dev`をターミナルで実行するだけです

```shell
foreman start -f Procfile.dev
```

`localhost:5000`にアクセスできればOkです(`foreman`を使用する場合、使用するポートが5000へと変更されています)

### 静的なファイルを作成

`rails g controller` コマンドを使い、コントローラーを作成します

```shell
rails g controller web index
```

その後、`config/routes.rb`を以下のように編集します

```ruby:config/routes.rb
Rails.application.routes.draw do
  root 'web#index'
end
```

`foreman start -f Procfile.dev`を実行して、`localhost:5000`でページが表示されていればOKです

### React.jsを使う

まず、`app/views/web/index.html.erb`を以下のように変更します

```erb:app/views/web/index.html.erb
<%= javascript_pack_tag 'hello_react' %>
```

最初に実行した`rails new`の段階で`app/javascript/packs/hello_react.js`が作成されています

それを`<%= javascript_pack_tag 'hello_react' %>`を使い、読み込んでいます

`app/views/web/index.html.erb`を編集後、`foreman start -f Procfile.dev`を実行して、`Hello React`と表示されていればOKです！

### React.js経由でBootstrapを使う

次に、`React.js`経由でBootstrapを使用してみたいと思います

まずは`yarn add react-bootstrap bootstrap`を実行し、`React.js`用の`Bootstrap`を導入します

```shell
yarn add react-bootstrap bootstrap
```

次に、各コンポーネントを作成していきます

`Header`コンポーネントとして利用する`app/javascript/packs/components/layouts/Header.jsx`を作成します

```jsx:app/javascript/packs/components/layouts/Header.jsx
import React from 'react'
import { Navbar, Nav, NavDropdown, Form, FormControl, Button,  } from 'react-bootstrap'

const Header = () => (
    <Navbar bg="light" expand="lg">
        <Navbar.Brand href="#home">React-Bootstrap</Navbar.Brand>
        <Navbar.Toggle aria-controls="basic-navbar-nav" />
        <Navbar.Collapse id="basic-navbar-nav">
            <Nav className="mr-auto">
                <Nav.Link href="#home">Home</Nav.Link>
                <Nav.Link href="#link">Link</Nav.Link>
                <NavDropdown title="Dropdown" id="basic-nav-dropdown">
                    <NavDropdown.Item href="#action/3.1">Action</NavDropdown.Item>
                    <NavDropdown.Item href="#action/3.2">Another action</NavDropdown.Item>
                    <NavDropdown.Item href="#action/3.3">Something</NavDropdown.Item>
                    <NavDropdown.Divider />
                    <NavDropdown.Item href="#action/3.4">Separated link</NavDropdown.Item>
                </NavDropdown>
            </Nav>
            <Form inline>
                <FormControl type="text" placeholder="Search" className="mr-sm-2" />
                <Button variant="outline-success">Search</Button>
            </Form>
        </Navbar.Collapse>
    </Navbar>
)

export default Header;
```

`react-bootstrap`は以下のように各コンポーネントを呼び出して使います

```js:
import { Navbar, Nav, NavDropdown, Form, FormControl, Button,  } from 'react-bootstrap'
```

次に、`Main`コンポーネントとして利用する`app/javascript/packs/components/layouts/Header.jsx`を作成します

```jsx:app/javascript/packs/components/layouts/Main.jsx
import React from 'react'

const Main = () => (
    <div className="container">
        <h1>Hello World! with React.js & Rails!</h1>
    </div>
)

export default Main;
```

`Footer`コンポーネントとして利用する`app/javascript/packs/components/layouts/Footer.jsx`作成します

```jsx:app/javascript/packs/components/layouts/Footer.jsx
import React from 'react'

const Footer = (props) => {
    const {year} = props
    return (
        <div>
            Created Time {year}
        </div>
    )
}

export default Footer;
```

あとは、`app/javascript/packs/index.js`を以下のように作成します

```js:app/javascript/packs/index.js
import React from 'react';
import ReactDOM from 'react-dom';

import Header from './components/layouts/Header'
import Main from './components/web/Main'
import Footer from './components/layouts/Footer'

class App extends React.Component {
    state = {
        year: 2019
    }
    render() {
        return (
            <div>
                <Header />
                <Main />
                <Footer year={this.state.year} />
            </div>
        );
    }
}

document.addEventListener("DOMContentLoaded", e => {
    ReactDOM.render(<App />, document.body.appendChild(document.createElement('div')))
})
```

最後に、`app/views/web/index.html.erb`を以下のように編集します

```erb:app/views/web/index.html.erb
<link
  rel="stylesheet"
  href="https://maxcdn.bootstrapcdn.com/bootstrap/4.2.1/css/bootstrap.min.css"
  integrity="sha384-GJzZqFGwb1QTTN6wy59ffF1BuGJpLSa9DkKMp0DgiMDm4iYMj70gZWKYbI706tWS"
  crossorigin="anonymous"
></link>

<%= javascript_pack_tag 'index' %>
```

`react-bootstrap`ではCSSが含まれていません

そのため、以下のようにCDN経由でCSSを導入する必要があります

```html:
<link
  rel="stylesheet"
  href="https://maxcdn.bootstrapcdn.com/bootstrap/4.2.1/css/bootstrap.min.css"
  integrity="sha384-GJzZqFGwb1QTTN6wy59ffF1BuGJpLSa9DkKMp0DgiMDm4iYMj70gZWKYbI706tWS"
  crossorigin="anonymous"
></link>
```

あとは、`foreman start -f Procfile.dev`をターミナルで実行します

`localhost:3000`にアクセスして`Bootstrap`が適用されていればOKです！