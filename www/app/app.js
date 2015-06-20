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

var SignUp = require('./signup');
var DhSignUp = require('./dh-signup');
var Employer = require('./employer');
var Home = require('./home');

var routes = (
    <Route handler={Main}>
        <DefaultRoute handler={Home}/>
        <Route name="home" path="" handler={Home}/>
        <Route name="signup" path="/signup" handler={SignUp}/>
        <Route name="dh-signup" path="/dh-signup" handler={DhSignUp}/>
        <Route name="employer" path="/employer" handler={Employer}/>
    </Route>
);

Router.run(routes, function (Handler/*, state*/) {
    React.render(<Handler/>, document.body);
});

Parse.initialize("Lq8BpgkIo7aoDpDOHjeqrKip6uH84elKKgLISFJW", "yFpw0CA2mI2fsGAU4YbGnEFUg5enFiVIYjuhvIHv");