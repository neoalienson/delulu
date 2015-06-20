var EventEmitter = require('events').EventEmitter;
var assign = require('object-assign');
var keyMirror = require('keymirror');

var EventTypes = keyMirror({
    USER_SIGNED_IN: null,
    USER_SIGNED_OUT: null
});

var SessionStore = assign({}, EventEmitter.prototype, {
    EventTypes: EventTypes,
    getUser: function () {
        return Parse.User.current()
    },
    signIn: function (username, password) {
        var that = this;
        Parse.User.logIn(username, password, {
            success: function (user) {
                that.emit(EventTypes.USER_SIGNED_IN);
            },
            error: function (user, error) {
                console.debug("sign-in failed: user=%o, error=%o", user, error);
                alert("Sign-in failed. " + error);
            }
        });
    },
    signOut: function() {
        Parse.User.logOut();
        this.emit(EventTypes.USER_SIGNED_OUT);
    }
});

module.exports = SessionStore;