---
layout: post
title: A Centralized Boom Server Using Redis
---

So, I've been thinking how cool it would be to setup a collaborative [Boom](http://zachholman.com/boom/) database. With its recent support for Redis and MongoDB, I figured it was a good time to give this crazy idea a whirl. So, let's run through the basic requirements to set this up. Fending off the baddies from deleting your beautiful lists is up to you, I must warn. What I'm going to explain in this example is how to do the following:

* Install Redis on a centralized server
* Install Boom
* Configure Boom to use the centralized server

#### Install Redis ####

Installing Redis is really easy. At the time of writing, the latest version of Redis is 2.2.2. Redis is under somewhat heavy development, so you may want to check to see if there's a newer version. To install 2.2.2, run the following in your teminal:
{% highlight bash %}
$ wget http://redis.googlecode.com/files/redis-2.2.2.tar.gz
$ tar xvzf redis-2.2.2.tar.gz
$ cd redis-2.2.2
$ make && make install
{% endhighlight %}

Now that Redis is installed, you can fire up the server with, strangely enough, <code>redis-server</code>. By default, it's going to run the server on port 6379. If you're running a firewall on the server you're installing this on (you are running a firewall, aren't you?), you will need to open up this port.

To test that everything's working, you can use the always handy telnet. In your command line, you can do the following:

{% highlight bash %}
$ telnet <hostname> 6379
> SET hello thar
> GET hello
{% endhighlight %}

You should get responses back from the Redis server showing that the value was stored during the <code>SET</code>, and return your "thar" when you <code>GET</code>. Redis *is* pretty cool, huh? 

#### Installing BOOM ####

Onto installing boom on your local machine. I'm going to assume you have ruby and rubygems already installed and setup. Boom, itself, has one dependency: yajl-ruby. If you don't already have this, go ahead and install it with <code>gem install yajl-ruby</code>. Once you've got yajl, a simple <code>gem install boom</code> will get you rolling with Boom. Now that you've got boom installed, run <code>boom</code> in your terminal to initialize your configuration file and your default .boom json file. Go ahead and give it a stab, and get a feel for how to use it. <code>boom help</code> will get you started. Once you're comfortable with its amazing powers of organization, let's move forward and configure it to use Redis.

#### Configuring Boom For Redis ####

To use Boom with our new Redis server, you'll need to install the Redis gem: <code>gem install redis</code>. Next, you'll need to crack open your newly created ~/.boom.conf file in your favorite text-editor, and edit it to look like this:

	{
	  "backend": "redis",
	  "redis": {
	    "port": "6379",
	    "host": "your-host-name.com"
	  }
	}
	
You'll obviously be swapping out the cleverly named "your-host-name.com" to whatever your hostname actually is. Once that bit of configuration is done, boom will be using your centralized redis database to store its contents. Neat! You and your friends or co-workers can now share this, and get into all sorts of mischief! Enjoy it.

#### Where To Go From Here ####

This is obviously not an ideal setup. It's open to anyone with an internet connection, so you may want to do IP-based verification, some kind of authentication scheme, etc. Your server is just running in your SSH session, if you stop with where I left you. You'll likely want to setup an rc.d / init.d script to fire up the redis server for you on startup. You also will probably want some kind of data persistence, since Redis stores all data in memory (although it will periodically dump to disk). 

In all, this is a pretty neat concept. I'm not sure how well it will work with co-workers or friends, since everyone has full read/write access to everything. But for compiling lists of funny image urls, command line one-liners, canned e-mail responses, etc., you may just find that this comes in handy if everyone is cooperative. 