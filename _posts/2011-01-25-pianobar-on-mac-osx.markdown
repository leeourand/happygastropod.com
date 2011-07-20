---
layout: post
title: Pianobar On Mac OS X
---

Recently, my friend [Brandon](http://redkrieg.com/2011/01/02/pianobar-an-open-source-pandora-client/) wrote about using [Pianobar](https://github.com/PromyLOPh/pianobar) on Linux (specifically on Debian based systems). In every attempt to steal his thunder, I'm copying him, and posting about how to get the same thing working on Mac OS X with similar functionality. 

For those unfamiliar, Pianobar is a command line interface to [Pandora](http://pandora.com), which is more gentle on your memory footprint (no Adobe anything!), and is easier to tuck away in the background. We're going to do a few things in this brief tutorial:

* Setup homebrew if you have not already
* Install Pianobar
* Install growlnotify
* Configure Pianobar
* Setup Growl notification for Pianobar


#### Installing Homebrew ####
Frankly, you should be ashamed of yourself if you haven't installed homebrew yet on your mac. To put it plainly, it's the bee's knees. Alright, now that you're convinced, let's get started.

Installation is really difficult, so be prepared for some heartache and pain. First, run this in your terminal:

{% highlight bash %}
curl -L http://github.com/mxcl/homebrew/tarball/master | tar xz --strip 1 -C /usr/local
{% endhighlight %}

AND THAT'S IT. Difficult, eh?

#### Installing Pianobar ####

So now that we've made it through that grueling task, we can move forward and install pianobar using our favorite package manager (in case you've forgotten already that's homebrew. We just installed it. Pay attention.) Run this whiz-bang command in your terminal:

{% highlight bash %}
brew install pianobar
{% endhighlight %}

BANG! You're ready to listen to some Pandora through your terminal. You can go ahead and try it out by typing <code>pianobar</code> in your terminal. Go ahead. I'll wait.

#### Install Growl Notify ####

This probably doesn't even merit its own step. But let's go ahead anyways. 

{% highlight bash %}
brew install growlnotify
{% endhighlight %}

#### Configure Pianobar ####

We're getting there. I'm proud of you for making it this far. Well done.

So Pianobar has a few things that you can set in a config file so that you don't have to set these each time you load the application. These are things like your Pandora username, your password, and something else we'll be talking about in the next section, the event_command. It sounds pretty complicated, but we'll get through it. I promise.

So, open up your favorite text editor (unless it's TextEdit, in which case, please just leave my site), and edit <code>~/.config/pianobar/config</code>. You'll enter in the following lines:

	user = you@youraddress.com
	password = hopefullyNot123456

Go ahead. Give Pianobar another whirl. It should log you in automatically. Pretty fancy, huh? Onward!

#### Setup Growl Notification #####

You can obviously skip this part if you find Growl obnoxious or annoying. I happen to like it. It's like a good friend who keeps you informed when exciting events are happening. I call him Ralph. 

So, don't get angry, but remember that pianobar configuration file? Yea? Ok, we're going to edit that once again. So open it up again in anything but TextEdit, and we're going to add this line to the bottom:

	event_command = /Users/yourusername/bin/pianobar-notify.rb

Obviously, you'll want to swap out "yourusername" for your actual username. If you don't know what it is, you can use the <code>whoami</code> command. You're welcome.

Now the exciting part. We're going to write a simple little program (in Ruby) to let us know some info about new songs that are being played through Pianobar. Ok, it's not really THAT exciting, but still pretty cool. Let's open up our text editors for one final edit. This time we're opening the <code>/Users/yourusername/bin/pianobar-notify.rb</code> file. Ok, now that you've got your file open (welcome back, by the way), you're going to type (or you can copy/paste if you really want to) this:

{% highlight ruby %}
#!/usr/bin/ruby

trigger = ARGV.shift

if trigger == 'songstart'
  songinfo = {}

  STDIN.each_line { |line| songinfo.store(*line.chomp.split('=', 2))}
  `growlnotify -t "Now Playing" -m "#{songinfo['title']}\nby #{songinfo['artist']}"`
end
{% endhighlight %}

Save the file, and you're done. You can now listen to your favorite tunes through the command line, see who's playing when new songs start, and you're now up to speed with the latest in package management fashion for the Mac platform.