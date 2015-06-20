/**
 * Created by lsiu on 6/20/2015.
 */

var React = require('react');

var About = React.createClass({
    render: function () {
        return (
            <div className="col-lg-4 col-lg-offset-4 col-md-4 col-md-offset-4 col-sm-6 col-sm-offset-3 col-xs-10 col-xs-offset-1">
                <h1>About Deulu</h1>

                <p>
                    Deulu <em>pronoun /day lu/</em>, means "Family" in Welsh. People who hires domestic helpers know
                    they are family. We believe we can make this family unit works together to achieve great things!
                </p>

                <p>
                    First thing first. Let's make life easier. Still tracking domestic expenses with pen and paper?
                    Welcome to the 21st century!. Use deulu now!
                </p>

                <h2>Why use Deulu?</h2>

                <h3>For employers</h3>

                <div>
                    <p>No more pen, paper and calculator to tally your expense. Easy to use weekly reports to
                    review you expense in seconds</p>

                    <img className="img-responsive" href="https://photos-1.dropbox.com/t/2/AAB73GUGD_DhCif0yrXOpO4liBDDjboB8449LPSsZUVHrg/12/22087001/png/32x32/1/_/1/2/em%20expense%20compare.png/CNmKxAogASACIAMgBCAFIAYgBygBKAIoAygH/X5YuKP5fWcAQbTEhSdwEWWDqwSVLaLCCuUrqY39oBpk?size=640x480&size_mode=2"/>

                </div>

            </div>
        )
    }
});

module.exports = About;