require('./shared/shared.less');
var React = require('react/react.js');
var Router = require('react-router');
var { Route, DefaultRoute, RouteHandler, /*Link*/ } = Router;
var Nav = require('./nav');

Parse.initialize("Lq8BpgkIo7aoDpDOHjeqrKip6uH84elKKgLISFJW", "yFpw0CA2mI2fsGAU4YbGnEFUg5enFiVIYjuhvIHv");

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

var Home = require('./home');

var routes = (
    <Route handler={Main}>
        <DefaultRoute handler={Home}/>
        <Route name="home" path="" handler={Home}/>
        <Route name="signup" path="/signup" handler={require('./signup')}/>
        <Route name="employer" path="/employer" handler={require('./employer')}/>
        <Route name="about" path="/about" handler={require('./about')}/>
        <Route name="signin" path="/signin" handler={require('./signin')}/>
        <Route name="household" path="/household/:id" handler={require('./household')}/>
    </Route>
);

Router.run(routes, function (Handler/*, state*/) {
    React.render(<Handler/>, document.body);
});