/**
 * Created by lsiu on 6/21/2015.
 */

var React = require('react');
var SessionStore = require('./stores/session');

var SignOut = React.createClass({
    contextTypes: {
        router: React.PropTypes.func
    },
    getInitialState: function() {
        SessionStore.signOut();
        this.context.router.transitionTo("/");
        return {};
    },
    render: function() {
        return <div/>;
    }
});

module.exports = SignOut;
