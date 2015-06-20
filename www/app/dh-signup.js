/**
 * Created by lsiu on 6/20/2015.
 */
var React = require('react');

var SignUp = React.createClass({
    contextTypes: {
        router: React.PropTypes.func
    },
    getInitialState: function () {
        return {householdName: "", email: "", password: "", dhEmail: ""}
    },
    render: function () {
        return (
            <div
                className="col-lg-4 col-lg-offset-4 col-md-4 col-md-offset-4 col-sm-6 col-sm-offset-3 col-xs-10 col-xs-offset-1">
                <div className="form-group">
                    <label htmlFor="householdName">Household name</label>
                    <div></div>
                    <input type="text" className="form-control" id="householdName" placeholder="Household Name" required
                           value={this.state.householdName} onChange={this.handleChange}
                           onBlur={this.handleHouseholdBlur}/>
                </div>
                <div className="form-group">
                    <label htmlFor="email">Email address</label>
                    <input type="email" className="form-control" id="email" placeholder="Your Email" required
                           value={this.state.email} onChange={this.handleChange}/>
                </div>

                <div className="form-group">
                    <label htmlFor="password">Password</label>
                    <input type="password" className="form-control" id="password" placeholder="Your Password" required
                           value={this.state.password} onChange={this.handleChange}/>
                </div>

                <button type="button" className="btn btn-default" onClick={this.handleSignUp}>Sign Up</button>
            </div>
        )
    },
    handleChange: function (ev) {
        var tmp = {};
        tmp[ev.target.id] = ev.target.value;
        this.setState(tmp);
    },
    handleSignUp: function () {
        var Household = Parse.Object.extend("Household");
        var Helper = Parse.Object.extend("Helper");

        var household = new Household();
        var helper = new Helper();
        var user = new Parse.User();

        household.set("name", this.state.householdName);

        user.set("username", this.state.email);
        user.set("password", this.state.password);
        user.set("email", this.state.email);
        user.set("type", "employee");
        user.set("parent", household);

        // other fields can be set just like with Parse.Object
        //user.set("dhEmail", this.state.dhEmail);

        var that = this;
        user.signUp(null, {
            success: function (user) {
                that.context.router.transitionTo("/#/employer");
            },
            error: function (user, error) {
                alert("Error: " + error.code + " " + error.message);
            }
        });

        if (this.state.dhEmail) {
            helper.set("email", this.state.dhEmail);
            helper.set("parent", household);
            helper.save();
        }
    },
    handleHouseholdBlur: function (ev) {
        console.debug("onblur");
        var Household = Parse.Object.extend("Household");
        var query = new Parse.Query(Household);
        query.equalTo("name", ev.target.value);
        query.find({
            success: function (results) {
                alert("Successfully retrieved " + results.length + " households.");
                // Do something with the returned Parse.Object values
                for (var i = 0; i < results.length; i++) {
                    var object = results[i];
                    alert(object.id + ' - ' + object.get('name'));
                }
            },
            error: function (error) {
                alert("Error: " + error.code + " " + error.message);
            }
        });

    }
});

module.exports = SignUp;