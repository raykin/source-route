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

#### In irb or pry

    SourceRoute.trace output_format: :console, event: :c_call do
      'abc'.upcase
    end

#### In rails console

    SourceRoute.trace defined_class: :ActiveRecord, output_format: :html do
      User.new
    end

It will generate a html file, open it and you can get the trace of User.new

The intereting part is when you run the above command again(in same console),
you will get a different trace file.

#### In your ruby application

    SourceRoute.enable do
      method_id :wanted_method_name
      full_feature
    end
    .... # here is your code
    ....
    ....
    # add it after your tracked code, it will output the trace into a html file
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
see full usage in examples/callback_in_activesupport.rb

## Why

I always wanna upgrade my ruby(rails) skills. But everytime when I looking for workaround from stack overflow I feel frustration.

To get solution or workaround from google or stack overflow is suitable when I'm a ruby starter or deadline is urgent. But it's not really helpful for my skills.

The way how I solve problem define my skills border and depth. So if I slove problems by search google and stack overflow with workarounds, I mostly just increase my experiences on ruby(rails). But if I solve problems directly, in most case, I can say my skill border extends.

That's why I create this gem. To solve problems directly, I need to know what happened in call or return traces.
Fortunately ruby 2.0 introduce a new feature TracePoint to easily trace inner event. But it's not easily to be used as daily tool. This gem tries to make tracing more readable and easily in our daily work.

Finally, I expect my working style can change from searching workaround from internet to reading code trace(then more easily check source) directly. I hope it can help you too.

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

Dynamic indent when new child level comes.

Animation when child was click.

Show loading when click clear. (when $apply() take more than 1 seconds to run)

Add debug option to provide more verbose messages of what has happened

Open File directly from browser(chrome) by plugin?
