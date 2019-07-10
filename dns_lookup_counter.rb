require 'coppertone'
require_relative './spf_record_fetcher'

class DNSLookupCounter
  LOOKUP_LIMIT = 10

  def count_dns_lookup(domain)
    return recursive_lookup(domain, 0, 1)
  end

  def recursive_lookup(domain, lookup_count = 0, depth = 0)
    values = fetcher.txt_record_values(domain)
    values.each do |value|
      next unless Coppertone::Record.record?(value[0])

      record = Coppertone::Record.new(value[0])
      lookup_count += record.dns_lookup_term_count

      raise 'TempError: dns lookup limit exceeded.' if lookup_count > LOOKUP_LIMIT

      record.includes.each do |include_v|
        lookup_count = recursive_lookup(include_v.mechanism.domain_spec.macro_text, lookup_count, depth+1)
      end
      lookup_count = recursive_lookup(record.redirect.domain_spec.macro_text, lookup_count, depth+1) unless record.redirect.nil?
    end

    return lookup_count
  end

  def fetcher
    @fetcher ||= SPFRecordFetcher.new
  end

end
