/**
 * Created by lsiu on 6/20/2015.
 */
var React = require('react')

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
            password: {value: "", status: ""}
        }
    },
    render: function () {
        return (
            <div
                className="col-lg-4 col-lg-offset-4 col-md-4 col-md-offset-4 col-sm-6 col-sm-offset-3 col-xs-10 col-xs-offset-1">
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
        var household;

        if (this.state.householdName.id) {
            household = this.state.householdName.id;
        } else {
            var Household = Parse.Object.extend("Household");
            household = new Household();
            household.set("name", this.state.householdName.value);
        }

        var user = new Parse.User();

        user.set("username", this.state.email.value);
        user.set("password", this.state.password.value);
        user.set("email", this.state.email.value);
        user.set("type", "helper");
        user.set("parent", household);

        var that = this;
        user.signUp(null, {
            success: function (user) {
                that.context.router.transitionTo("/#/helper");
            },
            error: function (user, error) {
                alert("Error: " + error.code + " " + error.message);
            }
        });

    },
    handleHouseholdBlur: function (ev) {
        console.debug("onblur");
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

    }
});

module.exports = SignUp;