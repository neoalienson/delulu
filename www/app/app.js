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
            <div
                className="col-lg-4 col-lg-offset-4 col-md-4 col-md-offset-4 col-sm-6 col-sm-offset-3 col-xs-10 col-xs-offset-1">
                <h1>Deulu</h1>

                <p>Make it fun and rewarding to keep track of household expenses</p>

                <div>
                    <img className="img-responsive" src="/img/helper.jpg"/>
                </div>

                <div className="row text-center spaced">
                    <div className="col-xs-6">
                        New user?<br/>
                        <a className="btn btn-default" href="/#/signup">Sign up</a>
                    </div>
                    <div className="col-xs-6">
                    Already a user?<br/>
                    <a className="btn btn-primary" href="/#/signin">Sign in</a>
                        </div>
                </div>
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