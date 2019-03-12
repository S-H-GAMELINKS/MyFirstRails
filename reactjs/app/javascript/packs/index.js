import React from 'react';

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

export default App;