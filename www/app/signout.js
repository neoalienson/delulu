/**
 * Created by lsiu on 6/21/2015.
 */

var React = require('react');

var SignOut = React.createClass({
    contextTypes: {
        router: React.PropTypes.func
    },
    render: function() {
        SessionStore.signOut();
        this.context.router.transitionTo("/");
        return null;
    }
});
