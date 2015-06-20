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

var routes = (
    <Route handler={Main}>
        <DefaultRoute handler={Index}/>
        <Route name="index" path="" handler={Index}/>
    </Route>
);

Router.run(routes, function (Handler/*, state*/) {
    React.render(<Handler/>, document.body);
});