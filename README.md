# SourceRoute

Wrapper of TracePoint

## Dependency

    ruby 2

## Installation

Add this line to your application's Gemfile:

    gem 'source_route', git: 'https://github.com/raykin/source-route'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install source_route

## Usage

    SourceRoute.enable /ActiveRecord/

## Contributing

1. Fork it ( https://github.com/[my-github-username]/source_route/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request


### TODO

Following code is a good sample that track file running sequence, how to change it into a good code design and merge into the gem

```ruby

    files = []
    tp = TracePoint.new(:line) do |tp|
      if tp.path =~ /bole_api/
        unless files.include? tp.path
          puts "#{tp.path}".inspect
          files.push(tp.path)
        end
      end
    end
    tp.enable

```
