# SpfLookup

SpfLookup will count the number of SPF lookups for a given domain.

## Overview

RFC specify a limit of 10 DNS lookups for SPF. https://datatracker.ietf.org/doc/html/rfc7208#section-4.6.4

Therefore, when configuring SPF, you need to check the number of SPF lookups for target domain and make sure that the number of lookups after configuration is within the upper limit set by the RFC.

SpfLookup will count the nubmer of SPF lookups by passing the domain,
so you can reduce the work of counting the number of SPF lookups.



## Installation

Add this line to your application's Gemfile:

```ruby
gem 'spf_lookup'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install spf_lookup

## Example

```ruby
require "spf_lookup"

domain = "sample.example.com"

resolv_conf = {
  nameserver: ['8.8.8.8']
}

# SpfLookup.dns_configure argumets is the same as the one passed to the initializer of Resolv::DNS
SpfLookup.dns_configure(resolv_conf)


# Retrive spf record set.
record_set = SpfLookup.retrieve_record_set(domain)
record_set_hash = record_set.to_hash

## record set information
puts record_set_hash[:lookup_term_count]
puts record_set_hash[:domain]
puts record_set_hash[:record_value]
puts record_set_hash[:includes]

puts record_set_hash[:includes].first[:lookup_term_count]
puts record_set_hash[:includes].first[:domain]
puts record_set_hash[:includes].first[:record_value]
puts record_set_hash[:includes].first[:includes]

# Lookup count check.
## If you want to use "retrieve_record_set" method, use this.
lookup_count = record_set.lookup_count
## If you DON'T want to use  "retrieve_record_set" method, use this.
lookup_count = SpfLookup.lookup_count(domain)

if lookup_count > SpfLookup::LOOKUP_LIMIT_SPECIFIED_BY_RFC7208
  puts "Invalid SPF lookup count!"
end

```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/shirot7335/spf_lookup. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## WIP
* test

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
