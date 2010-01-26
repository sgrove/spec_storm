SauceSpace
==========

SauceSpace allows you to run your selenium tests concurrently (at the file-level) without colliding with one another, and with almost no changes to your current rspec selenium specs. It hashes each spec file and then uses the hash as a database prefix, giving us a nice namespacing mechanism. It auto-patches rails' link-generation to append a db_prefix parameter, and dynamically resets the prefix on each request.

It also includes an rspec helper that patches the Selenium Driver class to calculate the db prefix, and will automatically append it to any "open" command.

Installation
============
SauceSpace relies on parallel_specs to execute the specs.

    sudo gem install parallel
    script/plugin install git://github.com/grosser/parallel_specs.git
    script/plugin install git://github.com/sgrove/special_sauce.git
    rake ss:setup

SauceSpace relies on parallel_specs as a launcher, so be sure to follow the [installation instructions](http://github.com/grosser/parallel_specs) - as a bonus, it will probably  speed up your non-selenium specs as well.

Usage
=====
Use the rake task ss:prepare in order to prepare the database before each run. You can pass it the environment to prepare for (required) and the path full of specs to namespace (optional). If you leave out the path, it prepares for every spec file.

The most common usage is:

    rake ss:prepare[selenium,integration]

Now start up a rails server with the appropriate environment with `script/server -e selenium`

For your specs, you'll want to add in the sauce_spec helper:

    require 'spec_helper'
    require 'sauce_spec_helper'

And finally, you can run your Selenium specs in parallel:

    rake parallel:specs[4,integration]

Sit back and watch as multiple browsers hit the same rails server and each sees a pristine environment!

TODO
====
* Data interactions: Since a rails server is running, any data you create outside of your selenium script won't be accessible. This includes fixtures. This should be fixed next release
* Wrap it all into a nicer execution model. e.g. `rake ss[integration]` should reset the database, start the server, run the specs, and stop the server. Right now it's a bit too manual
* Unit tests

Thanks
======
* Thanks to [Michael Grosser](http://pragmatig.wordpress.com/) for the parallel_specs plugin, which had some great pointers.
* And thanks to [Sauce Labs](https://saucelabs.com/), for their push into concurrent testing.

Copyright (c) 2010 Sauce Labs Inc, released under the MIT license
