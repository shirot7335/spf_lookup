require "spf_lookup/version"

require_relative './spf_lookup/dns_lookup_counter'

module SpfLookup

  # 'options' could set nil or Resolv::DNS.new argument.
  # ex.
  #   {nameserver: '8.8.8.8'}
  DNS_CONFIG = {option: nil}
  class << self
    def lookup_count(domain)
      return SpfLookup::DNSLookupCounter.count(domain)
    end

    def dns_configure(dns_config = nil)
      DNS_CONFIG[:option] = dns_config
    end
  end

end

