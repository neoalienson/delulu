/**
 * Created by lsiu on 6/20/2015.
 */
var React = require('react');
var UserStore = require('./stores/user');
var SessionStore = require('./stores/session');

function _getStatusStyle(status) {
    switch (status) {
        case "":
        case undefined:
            return "";
        default:
            return "has-" + status;
    }
}

function _getGlyphiconStyle(status) {
    switch (status) {
        case "":
        case undefined:
            return "";
        case "warning":
            return "glyphicon-warning-sign";
        case "error":
            return "glyphicon-remove";
        case "success":
            return "glyphicon-ok";
        default:
            return "glyphicon-" + status;
    }
}

var SignIn = React.createClass({
    contextTypes: {
        router: React.PropTypes.func
    },
    getInitialState: function () {
        this.handleSessionChanged();
        return {
            email: {value: "", status: ""},
            password: {value: "", status: ""},
            type: {value:"employer", status:""}
        }
    },
    componentWillMount: function () {
        SessionStore.on(SessionStore.EventTypes.USER_SIGNED_IN, this.handleSessionChanged);
        SessionStore.on(SessionStore.EventTypes.USER_SIGNED_OUT, this.handleSessionChanged);

    },
    componentWillUnmount: function () {
        SessionStore.removeListener(SessionStore.EventTypes.USER_SIGNED_IN, this.handleSessionChanged);
        SessionStore.removeListener(SessionStore.EventTypes.USER_SIGNED_OUT, this.handleSessionChanged);
    },
    render: function () {
        return (
            <div
                className="col-lg-4 col-lg-offset-4 col-md-4 col-md-offset-4 col-sm-6 col-sm-offset-3 col-xs-10 col-xs-offset-1">
                <h1>Sign in</h1>
                <div className="form-group">
                    <label htmlFor="email">Email address</label>
                    <input type="email" className="form-control" id="email" placeholder="Your Email" required
                           value={this.state.email.value} onChange={this.handleChange}/>
                </div>

                <div className="form-group">
                    <label htmlFor="password">Password</label>
                    <input type="password" className="form-control" id="password" placeholder="Your Password" required
                           value={this.state.password.value} onChange={this.handleChange}/>
                </div>

                <button type="button" className="btn btn-default" onClick={this.handleSignIn}>Sign In</button>
            </div>
        )
    },
    handleChange: function (ev) {
        this.state[ev.target.id].value = ev.target.value;
        this.setState(this.state);
    },
    handleSignIn: function () {
        SessionStore.signIn(this.state.email.value, this.state.password.value);
    },
    handleSessionChanged: function() {
        var user = SessionStore.getUser();
        if (user) {
            var that = this;
            this.context.router.transitionTo('/household/' + user.attributes.parent.id);
        }
    }
});

module.exports = SignIn;