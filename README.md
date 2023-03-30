# RailInspector

A collection of linters for [`rails/rails`](https://github.com/rails/rails)

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add rail_inspector

If bundler is not being used to manage dependencies, install the gem by
executing:

    $ gem install rail_inspector

## Usage

```console
$ railspect
Commands:
  railspect changelogs RAILS_PATH     # Check CHANGELOG files for common issues
  railspect configuration RAILS_PATH  # Check various Configuration issues
  railspect help [COMMAND]            # Describe available commands or one specific command
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake test` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and the created tag, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/skipkayhil/rail_inspector.

## License

The gem is available as open source under the terms of the [MIT
License](https://opensource.org/licenses/MIT).
