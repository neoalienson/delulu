var EventEmitter = require('events').EventEmitter;
var assign = require('object-assign');
var keyMirror = require('keymirror');

var EventTypes = keyMirror({
    USER_CREATED: null
});

var UserStore = assign({}, EventEmitter.prototype, {
    EventTypes: EventTypes,
    createUser: function (h, u, successCallback, errorCallback) {
        var household;

        if (h.id) {
            household = h.id;
        } else {
            var Household = Parse.Object.extend("Household");
            household = new Household();
            household.set("name", h.value);
        }

        var user = new Parse.User();

        user.set("username", u.email);
        user.set("password", u.password);
        user.set("email", u.email);
        user.set("type", u.type);
        user.set("parent", household);

        var that = this;
        user.signUp(null, {
            success: function (user) {
                that.emit(EventTypes.USER_CREATED);
                if (successCallback) successCallback(user);
            },
            error: function (user, err) {
                errorCallback(user, err);
            }
        });
    }
});

module.exports = UserStore;