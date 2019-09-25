require 'coppertone'
require_relative './spf_record_fetcher'

module SpfLookup
  class DNSLookupCounter

    LOOKUP_LIMIT_SPECIFIED_BY_RFC7208 = 10

    class << self

      def count_dns_lookup(domain)
        return __count__(domain, lookup_count = 0, depth = 1)
      end

      private
      def __count__(domain, lookup_count = 0, depth = 0)
        counter      = -> (domain) { __count__(domain, lookup_count, depth+1) }
        text_fetcher = -> (obj)    { obj.domain_spec.macro_text }

        record_fetcher.txt_record_values(domain).each do |value|
          next unless Coppertone::Record.record?(value)

          record = Coppertone::Record.new(value)
          lookup_count += record.dns_lookup_term_count

          return lookup_count if lookup_count > LOOKUP_LIMIT_SPECIFIED_BY_RFC7208

          record.includes.each { |include_value|
            lookup_count = counter.call(text_fetcher.(include_value.mechanism))
          }

          lookup_count = counter.call(text_fetcher.(record.redirect)) unless record.redirect.nil?
        end

        return lookup_count
      end

      def record_fetcher
        @fetcher ||= SPFRecordFetcher.new(SpfLookup::DNS_CONFIG[:option])
      end

    end
  end
end
