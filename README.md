# SourceRoute

Trace ruby code

## Dependency

    ruby 2

## Installation

Add this line to your application's Gemfile:

    gem 'source_route'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install source_route

## Usage

#### In irb or pry

    SourceRoute.trace(output_format: :console, event: :c_call) { 'abc'.upcase }

#### In rails console or test code

    SourceRoute.trace(defined_class: 'ActiveRecord::Attribute', output_format: :html) { User.new }

It will generate a html file, open it and you can get the trace of User.new

The intereting part is when you run the above command again(in same console),
you will get a different trace file.

#### In your ruby application

    SourceRoute.enable do
      method_id :wanted_method_name
      full_feature
      filename 'tmp/capture_wanted.html'
    end
    # Following is your code
    ....
    ....
    ....
    # add it after your tracked code, it output the trace into a html file
    SourceRoute.output_html

Same as the previous example, you will get a html file showing the code trace.

#### In a small application, you may try this

    SourceRoute.enable do
      defined_class :wanted_class_name
      output_format :console
    end
    .... # here is your code

It will output the trace when you run the application.

see more usage in examples.
see full usage in examples/study_callback.rb

![Study Callback Example](https://cloud.githubusercontent.com/assets/490502/9052549/746b36d2-3a9b-11e5-9e3e-fc9f149bc56c.png)

## Why

Help me read source code and solve problem directly.

## Test

    $ bundle install
    $ rake

## Contributing

1. Fork it ( https://github.com/raykin/source_route/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

### TODO

add syntax to monitor when obj was passed into method

animation when node hide

use concurrent-ruby to speed up

call and return event combined together is no useful. So traces data structure need changed.
Dynamic indent when new child level comes.

global disable some class from monitor

Add debug option to provide more verbose messages of what has happened

if instance val contains symbol as value, the json output will be string. It could be confused others.

Open File directly from browser(chrome) by plugin? Maybe check out how better error implement this
