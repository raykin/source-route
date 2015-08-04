require "bundler/gem_tasks"

task default: :test
task :test do
  ENV['ignore_html_generation'] = 'false'
  $LOAD_PATH.unshift('lib', 'test')
  Dir.glob('./test/**/*_test.rb') { |f| require f }
end
