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
            <div className="col-lg-4 col-lg-offset-4 col-md-4 col-md-offset-4 col-sm-6 col-sm-offset-3 col-xs-10 col-xs-offset-1">
                <div className="form-group">
                    <label for="householdName">Household name</label>
                    <input type="text" className="form-control" id="householdName" placeholder="Household Name" required
                           value={this.state.householdName} onChange={this.handleChange}/>
                </div>
                <div className="form-group">
                    <label for="email">Email address</label>
                    <input type="email" className="form-control" id="email" placeholder="Your Email" required
                        value={this.state.email} onChange={this.handleChange}/>
                </div>

                <div className="form-group">
                    <label for="password">Password</label>
                    <input type="password" className="form-control" id="password" placeholder="Your Password" required
                           value={this.state.password} onChange={this.handleChange}/>
                </div>

                <hr/>
                <p>
                    Invite your domestic helper!<br/>
                    <em>(You can do this later)</em>
                </p>

                <div className="form-group">
                    <label for="dhEmail">Domestic Helper's Email</label>
                    <input type="text" className="form-control" id="dhEmail" placeholder="Domestic Helper's Email" required
                           value={this.state.dhEmail} onChange={this.handleChange}/>
                </div>

                <button type="button" className="btn btn-default" onClick={this.handleSignUp}>Sign Up</button>
            </div>
        )
    },
    handleChange: function(ev) {
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
    }
});

module.exports = SignUp;