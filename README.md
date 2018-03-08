# README

This is an example app that I built for a company looking to hire me for a crawling / indexing job.

Here's what you need to know:

* Ruby 2.3.x / 2.4.x
* Sidekiq 4 or 5
* Database (I used MySQL but anything with ActiveRecord support)
* Rails 4 or 5 but almost anything relatively modern would work 

## Test Suite

bundle exec rspec 

## Installing

1.  Do a git clone.  
2.  Start two terminal windows on this directory.
3.  Run bundle exec rake db:create (you may need to set the db password in config/database.yml)
4.  In terminal window number 1, run bundle exec sidekiq
5.  In terminal window number 2 run bundle exec rails c
6.  In terminal window number 2, give the command PublisherCrawlerWorker.new.perform("vice.com")

Sidekiq should then do its thing and you can check the results by looking at:

Website.all 

DomainCountry.all

## Other Stuff

I build a fair number of side projects so there's some carry over from existing projects of mine.  Specifically

* a number of libraries in app/models named *_common.rb -- these are class libraries that I use for url handling, text manipulation and so on.  An example call is status, page = UrlCommon.get_page("http://www.vice.com") which handles fetching a url with Mechanize and returning a page object
* a page parser named page_alexa_site.rb which returns the audience data for a given url parsed from the Alexa data for a given domain.  Over the past year, I've written 70 or so of these parsers using this approach and they are a convenient tool for extracting data from a given web page into a native ruby structure (usually an array of hashes but that's really up to the implementor).  There are some other supporting files for this approach like parser_page_base.rb (shared methods) and select_page_parser.rb (which allows a url to dynamically select the parser needed).  Data extraction is handled using Nokogiri expressions although I built it to cleanly support both Nokogiri and Regex operations on the same source url.


# Specification

The specification for this is located in docs/spec.txt with each requirement checked off denoted by [SJ].

# Rails New Statement

Always useful to have a record of how the app was created since sometimes there are long term consequences.  I used:

rails new buzzsumo --database=mysql –skip-action-cable –skip-spring –api -T

I'm not a big fan of spring.  Spring works great when there is one rails app.  But when you have something that is say seven discrete parts (example a decomposed monolith) and then it gets flaky in my experience.

