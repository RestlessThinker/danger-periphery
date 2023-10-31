# danger-periphery

A [Danger](https://github.com/danger/danger) plugin for [Periphery](https://github.com/peripheryapp/periphery) reports that checks for unused code.

## Installation

Add this line to your Gemfile:
```rb
gem 'danger-periphery'
```

## Usage

You'll have to output a json report from Periphery

```ruby
# Dangerfile
periphery.report("report.json")
```

## License

MIT
