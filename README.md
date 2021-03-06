# amqp-failover #

Add multi-server support with failover and fallback to the [amqp](https://github.com/ruby-amqp/amqp) gem. Failover is configured by providing multiple servers/configurations to `AMQP.start` or `AMQP.connect`. Both methods will still accept the same options input as they always have, they simply now support additional forms of options which when used, enables the failover features.


## Installation ##

    gem install amqp-failover


## Basic Usage ##

    require 'mq'
    require 'amqp/failover'
    opts = [{:port => 5672}, {:port => 5673}]
    AMQP.start(opts) do
      # code...
    end

By default the client will connect to `localhost:5672`, but if for any reason it can't connect, or looses connection to that server, it'll attempt to connect to `localhost:5673` instead.


## Options Formats ##

### Standard Non-Failover ###

Hash:

    opts = {:host => "hostname", :port => 5673}

URL:

    opts = "amqp://user:pass@hostname:5673/"

### With Failover ###

URLs

    opts = "amqp://localhost:5672/,amqp://localhost:5673/"

Array of Hashes:

    opts = [{:port => 5672}, {:port => 5673}]

Array of URLs:

    opts = ["amqp://localhost:5672/", "amqp://localhost:5673/"]

Specify AMQP servers and Failover options by passing a Hash containing a `:hosts` key with a value of either of the above three examples:

    opts = {:hosts => "amqp://localhost:5672/,amqp://localhost:5673/", :fallback => true}
    opts = {:hosts => [{:port => 5672}, {:port => 5673}], :fallback => true}
    opts = {:hosts => ["amqp://localhost:5672/", "amqp://localhost:5673/"], :fallback => true}

## Failover Options ##

* `:retry_timeout`, time to wait before retrying a specific AMQP config after failure.
* `:primary_config`, specify which of the supplied configurations is it the primary one. The default value is 0, the first item in the config array. Use 1 for the second and so on.
* `:fallback`, check for the return of the primary server, and fallback to it if and when it returns. WARNING: This currently calls `Process.exit` cause I haven't figured out a way to artificially kill the EM connection without the AMQP channels also being closed, which causes nothing to work even after EM connects to the primary server. It works for me cause dead workers are automatically relaunched with their default config.
* `:fallback_interval`, seconds between each check for original server if :fallback is true.
* `:selection`, not yet implemented.


## Notes ##

I would recommend you test the failover functionality in your own infrastructure before deploy to production, as this gem is still very much alpha/beta quality, and it does do a little bit of monkey patching to the amqp gem. That said, it there's a number of specs which should ensure things work as advertised, and nothing breaks. We are currently using it at Global Personals without any problems.


## Todo ##

* Figure out a sane way to fallback without having to kill the Ruby process.
* Better Readme/Documentation.
* Add option for next server selection on failover to be selected by random rather than next on the list.
* Convince get failover functionality merged in, or otherwise rewritten/added to the official AMQP gem.


## Note on Patches/Pull Requests ##
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.


## Licensing and Attribution ##

Copyright (c) 2011 Global Personals, Ltd.

Released under the MIT license as detailed in the [LICENSE](https://github.com/jimeh/amqp-failover/blob/master/LICENSE) file. Developed by [Jim Myhrberg](http://jimeh.me/) during work on [White Label Dating](http://www.whitelabeldating.com/), while employed by [Global Personals Ltd](http://www.globalpersonals.co.uk).  Global Personals Ltd have kindly agreed to the extraction and release of this software under the license terms above.
