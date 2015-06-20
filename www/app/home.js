var React = require('react');

var Home = React.createClass({
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
                        New User?
                    </div>
                    <div className="col-xs-6">
                        Already a user?
                    </div>
                </div>
                <div className="row text-center spaced">
                    <div className="col-xs-6">
                        <a className="btn btn-default" href="/#/signup">Sign up</a>
                    </div>
                    <div className="col-xs-6">
                        <a className="btn btn-primary" href="/#/signin">Sign in</a>
                    </div>
                </div>
            </div>
        )
    }
});

module.exports = Home;