/**
 * Created by lsiu on 6/20/2015.
 */
var React = require('react')
var UserStore = require('./stores/user');

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

var SignUp = React.createClass({
    contextTypes: {
        router: React.PropTypes.func
    },
    getInitialState: function () {
        return {
            householdName: {value: "", status: ""},
            email: {value: "", status: ""},
            password: {value: "", status: ""},
            type: {value:"employer", status:""}
        }
    },
    componentWillMount: function () {
        UserStore.on(UserStore.EventTypes.USER_CREATED, this.handleUserCreated);
    },
    componentWillUnmount: function () {
        UserStore.removeListener(UserStore.EventTypes.USER_CREATED, this.handleUserCreated);
    },
    render: function () {
        return (
            <div className="col-lg-4 col-lg-offset-4 col-md-4 col-md-offset-4 col-sm-6 col-sm-offset-3 col-xs-10 col-xs-offset-1">
                <h1>Sign up</h1>
                <div className="form-group">
                    <label htmlFor="type">I am a</label>
                    <select className="form-control" id="type" onChange={this.handleChange} defaultValue={this.state.type.value}>
                        <option value="employer">employer of domestic helper</option>
                        <option value="helper">domestic helper</option>
                    </select>
                </div>

                <div className={"form-group " + _getStatusStyle(this.state.householdName.status)}>
                    <label className="control-label" htmlFor="householdName">Household name</label>
                    <input type="text" className="form-control" id="householdName" placeholder="Household Name" required
                           aria-describedby
                           value={this.state.householdName.value} onChange={this.handleChange}
                           onBlur={this.handleHouseholdBlur}/>
                    <span
                        className={"glyphicon form-control-feedback " + _getGlyphiconStyle(this.state.householdName.status)}
                        aria-hidden="true"></span>
                    <span id="householdNameStatus" className="sr-only">Testing</span>
                    <span className={"help-block " + (this.state.householdName.message?"show":"hidden")}>
                        {this.state.householdName.message}</span>
                </div>

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

                <button type="button" className="btn btn-default" onClick={this.handleSignUp}>Sign Up</button>
            </div>
        )
    },
    handleChange: function (ev) {
        this.state[ev.target.id].value = ev.target.value;
        this.setState(this.state);
    },
    handleSignUp: function () {
        var h = { id: this.state.householdName.id, value: this.state.householdName.value };
        var u = { email: this.state.email.value, password: this.state.password.value, type: this.state.type.value };

        var that = this;
        UserStore.createUser(h, u, null, function (user, error) {
                alert("Error: " + error.code + " " + error.message);
            }
        );

    },
    handleHouseholdBlur: function (ev) {
        var Household = Parse.Object.extend("Household");
        var query = new Parse.Query(Household);
        var value = ev.target.value;
        query.equalTo("name", value);
        var that = this;
        query.find({
            success: function (results) {
                if (results.length == 0) {
                    that.setState({
                        householdName: {
                            status: "warning",
                            message: "No household found. Create one?",
                            value: value
                        }
                    });
                } else if (results.length == 1) {
                    that.setState({
                        householdName: {
                            status: "success",
                            message: "Househould found. Join it?",
                            value: value,
                            id: results[0]
                        }
                    });
                } else {
                    that.setState({
                        householdName: {
                            status: "danger",
                            message: "More than one household found with same name!!",
                            value: value
                        }
                    });
                }
            },
            error: function (error) {
                alert("Error: " + error.code + " " + error.message);
            }
        });

    },
    handleUserCreated : function() {
        //this.context.router.transitionTo("/helper");
        window.location.href="/tableResult.html"
    }
});

module.exports = SignUp;