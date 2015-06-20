var EventEmitter = require('events').EventEmitter;
var assign = require('object-assign');
var keyMirror = require('keymirror');

var EventTypes = keyMirror({
    LOADED: null
});

var _household = {};

var HouseholdStore = assign({}, EventEmitter.prototype, {
    EventTypes: EventTypes,
    getHousehold: function() {
      return _household;
    },
    fetch: function(id) {
        var Household = Parse.Object.extend("Household");
        var query = new Parse.Query(Household);
        var that = this;
        query.get(id, {
            success: function(result) {
                _household.id = result.id;
                _household.name = result.get("name");
                that.emit(EventTypes.LOADED);
            },
            error: function(object, error) {
                alert('error loading household: ' + error.message);
            }
        });
    }
});

module.exports = HouseholdStore;