require "spf_lookup/version"
require_relative './dns_lookup_counter'

module SpfLookup
  class Error < StandardError; end

  attr_reader :domain, :lookup_upper_limit

  def initialize(domain, lookup_upper_limit = 10)
    @domain = domain
    @lookup_upper_limit = lookup_upper_limit
  end

  def registerable?
    lookup_count <= @lookup_upper_limit
  end

  def lookup_count
    counter.count_dns_lookup(@domain)
  end

  def counter
    @counter ||= DNSLookupCounter.new
  end


end

