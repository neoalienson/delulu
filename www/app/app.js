require('./shared/shared.less');
var React = require('react/react.js');
var Router = require('react-router');
var { Route, DefaultRoute, RouteHandler, /*Link*/ } = Router;
var Nav = require('./nav');

var Main = React.createClass({
    render: function () {
        return (
            <div id="content">
                <Nav/>
                <RouteHandler/>
            </div>
        )
    }
});

var Index = React.createClass({
    render: function () {
        return (
            <div>
                <div>Hello world!</div>
                <div><a href="#" className="btn btn-primary" onClick={ this.handleClick }>Primary</a></div>
            </div>
        )
    },
    handleClick: function () {
        throw Error("Error message");
    }
});

var SignUp = require('./signup');
var Employer = require('./employer');

var routes = (
    <Route handler={Main}>
        <DefaultRoute handler={Index}/>
        <Route name="index" path="" handler={Index}/>
        <Route name="signup" path="/signup" handler={SignUp}/>
        <Route name="employer" path="/employer" handler={Employer}/>
    </Route>
);

Router.run(routes, function (Handler/*, state*/) {
    React.render(<Handler/>, document.body);
});

Parse.initialize("Lq8BpgkIo7aoDpDOHjeqrKip6uH84elKKgLISFJW", "yFpw0CA2mI2fsGAU4YbGnEFUg5enFiVIYjuhvIHv");