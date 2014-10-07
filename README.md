# SourceRoute

Wrapper of TracePoint

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

In irb or pry terminal
    SourceRoute.trace output_format: :console, event: :c_call do
      'abc'.upcase
    end

In rails console
    SourceRoute.trace defined_class: 'ActiveRecord', output_format: html do
      User.new
    end
It will generate a html file, open it and you can get the trace of User.new

The intereting part is when you run the above command again(in same console),
you will get a different trace file.

In your ruby application
    SourceRoute.enable :wanted_method_name
    .... # here is your code
    ....
    # may be code this in another file
    SourceRoute.build_html_output
Same as the previous example, you will get a html file showing the code trace.

In a short application, you may try this
    SourceRoute.enable do
      defined_class :wanted_class_name
      output_format :console
    end
    .... # here is your code
It will output the trace when you run the application.

see more usage in examples.

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

Add debug option to provider more verbose messages of what has happened

Support SourceRoute.enable :wanted_method_or_class, at now only SourceRoute.enable :wanted_method works
