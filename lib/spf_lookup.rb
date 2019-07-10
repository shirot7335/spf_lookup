require "spf_lookup/version"

require_relative './spf_lookup/dns_lookup_counter'

module SpfLookup

  class << self
    def lookup_count(domain)
      return SpfLookup::DNSLookupCounter.count_dns_lookup(domain)
    end

    DNS_CONFIG = {option: {} }

    def dns_configure(dns_config = {})
      DNS_CONFIG[:option] = dns_config
    end
  end

end

