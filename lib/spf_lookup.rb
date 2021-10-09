require "spf_lookup/version"

require_relative './spf_lookup/lookup'

module SpfLookup

  # 'options' could set nil or Resolv::DNS.new argument.
  # ex.
  #   {nameserver: '8.8.8.8'}
  DNS_CONFIG = {option: nil}
  LOOKUP_LIMIT_SPECIFIED_BY_RFC7208 = 10

  class << self
    def retrieve_record_set(domain)
      return SpfLookup::Lookup.run(domain)
    end

    def lookup_count(domain)
      return SpfLookup::Lookup.run(domain).lookup_count
    end

    def dns_configure(dns_config = nil)
      DNS_CONFIG[:option] = dns_config
    end
  end

end

