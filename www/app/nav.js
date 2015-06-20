var React = require('react');
var UserStore = require('./stores/user');
var SessionStore = require('./stores/session');

var Nav = React.createClass({
    getInitialState: function () {
        return {user: SessionStore.getUser()};
    },
    componentWillMount: function () {
        UserStore.on(UserStore.EventTypes.USER_CREATED, this.handleSessionChanged);
        SessionStore.on(SessionStore.EventTypes.USER_SIGNED_IN, this.handleSessionChanged);
        SessionStore.on(SessionStore.EventTypes.USER_SIGNED_OUT, this.handleSessionChanged);

    },
    componentWillUnmount: function () {
        UserStore.removeListener(UserStore.EventTypes.USER_CREATED, this.handleSessionChanged);
        SessionStore.removeListener(SessionStore.EventTypes.USER_SIGNED_IN, this.handleSessionChanged);
        SessionStore.removeListener(SessionStore.EventTypes.USER_SIGNED_OUT, this.handleSessionChanged);
    },
    render: function () {
        console.debug("session.user: %o", SessionStore.getUser());
        var signInOut = (
            <ul className="nav navbar-nav">
                <li><a href="#/signup">Sign up</a></li>
                <li><a href="#/signin">Sign in</a></li>
            </ul>
        );
        if (this.state.user) {
            signInOut = (
                <ul className="nav navbar-nav">
                    <li><a onClick={this.handleSignOut}>Sign out</a></li>
                </ul>
            )
        }
        return (
            <nav className="navbar navbar-inverse">
                <div className="container-fluid">
                    <div className="navbar-header">
                        <button type="button" className="navbar-toggle collapsed" data-toggle="collapse"
                                data-target="#navbar-collapse-1">
                            <span className="sr-only">Toggle navigation</span>
                            <span className="icon-bar"></span>
                            <span className="icon-bar"></span>
                            <span className="icon-bar"></span>
                        </button>
                        <a className="navbar-brand logo" href="#"></a>
                    </div>
                    <div className="collapse navbar-collapse" id="navbar-collapse-1">
                        {signInOut}
                        <ul className="nav navbar-nav navbar-right">
                            <li className="dropdown">
                                <a href="#" className="dropdown-toggle" data-toggle="dropdown" role="button"
                                   aria-expanded="false">Help <span className="caret"></span></a>
                                <ul className="dropdown-menu" role="menu">
                                    <li><a href="#/about">About</a></li>
                                </ul>
                            </li>
                        </ul>
                    </div>
                </div>
            </nav>
        )
    },
    handleSignOut: function () {
        SessionStore.signOut();
    },
    handleSessionChanged: function () {
        this.setState({user: SessionStore.getUser()});
    }
});

module.exports = Nav;