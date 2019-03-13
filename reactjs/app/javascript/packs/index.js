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