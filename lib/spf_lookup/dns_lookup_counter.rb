require 'coppertone'
require_relative './spf_record_fetcher'

class SpfLookup
  class DNSLookupCounter

    LOOKUP_LIMIT = 10

    class << self

      def count_dns_lookup(domain)
        return __lookup__(domain, lookup_count = 0, depth = 1)
      end

      private
      def __count__(domain, depth = 0)
        counter      = -> (domain) { __count__( domain, depth+1) }
        text_fetcher = -> (obj)    { obj.domain_spec.macro_text }

        record_fetcher.txt_record_values(domain).each do |value|
          next unless Coppertone::Record.record?(value[0])

          record = Coppertone::Record.new(value[0])
          lookup_count += record.dns_lookup_term_count

          return lookup_count if lookup_count > LOOKUP_LIMIT

          record.includes.reduce(lookup_count) { |memo, include_v|
            memo += counter.call(text_fetcher.(include_value.mechanism))
          }

          lookup_count += counter.call(text_fetcher.(record.redirect)) unless record.redirect.nil?
        end

        return lookup_count
      end

      def record_fetcher
        @fetcher ||= SPFRecordFetcher.new(SpfLookup::DNS_CONFIG)
      end

    end

  end
end
