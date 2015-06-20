/**
 * Created by lsiu on 6/21/2015.
 */

var React = require('react');
var HouseholdStore = require('./stores/household');

var Household = React.createClass({
    contextTypes: {
        router: React.PropTypes.func
    },
    getInitialState: function () {
        HouseholdStore.fetch(this.context.router.getCurrentParams().id)
        return {household: HouseholdStore.getHousehold()};
    },
    componentWillMount: function () {
        HouseholdStore.on(HouseholdStore.EventTypes.LOADED, this.handleLoaded);

    },
    componentWillUnmount: function () {
        HouseholdStore.removeListener(HouseholdStore.EventTypes.LOADED, this.handleLoaded);
    },
    render: function () {
        return (
            <div className="container">
                <h1>Household - {this.state.household.name}</h1>
                <table className="container">
                    <thead>
                    <tr className="row">
                        <th className="col-lg-1 col-md-1 col-sm-2 col-xs-2">Date</th>
                        <th className="col-lg-9 col-md-9 col-sm-6 col-xs-6">Item</th>
                        <th className="col-lg-1 col-md-1 col-sm-2 col-xs-2">Amount</th>
                        <th className="col-lg-1 col-md-1 col-sm-2 col-xs-2">Region Average</th>
                    </tr>
                    </thead>
                    <tbody>
                    <tr className="row">
                        <td className="col-lg-1 col-md-1 col-sm-2 col-xs-2">2015-06-12</td>
                        <td className="col-lg-9 col-md-9 col-sm-6 col-xs-6">Carrot</td>
                        <td className="col-lg-1 col-md-1 col-sm-2 col-xs-2">$15.99</td>
                        <td className="col-lg-1 col-md-1 col-sm-2 col-xs-2">$12.45</td>
                    </tr>
                    </tbody>
                </table>
            </div>
        )
    },
    handleLoaded: function () {
        this.setState({household: HouseholdStore.getHousehold()})
    }
});

module.exports = Household;