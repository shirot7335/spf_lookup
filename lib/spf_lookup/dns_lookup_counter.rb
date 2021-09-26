require 'coppertone'
require_relative './spf_record_fetcher'
require_relative './error'

module SpfLookup
  class DNSLookupCounter

    LOOKUP_LIMIT_SPECIFIED_BY_RFC7208 = 10

    class << self
      def count_dns_lookup(domain)
        spf_record = find_spf_record(domain)

        domains = fetch_lookup_target_domains(spf_record)

        _lookup_count = spf_record.dns_lookup_term_count
        domains.compact.each do |domain|
          _lookup_count += count_dns_lookup(domain)
        end

        return _lookup_count
      end

      def count_is_valid?(domain)
        return self.count_dns_lookup(domain) <= LOOKUP_LIMIT_SPECIFIED_BY_RFC7208
      end

      private

      def fetch_lookup_target_domains(spf_record)
        domain_fetcher = -> (obj) { obj.domain_spec.macro_text }

        domains = spf_record.includes.each_with_object([]) { |include_value, memo|
          memo << domain_fetcher.(include_value.mechanism)
        }
        domains << domain_fetcher.(spf_record.redirect) unless spf_record.redirect.nil?

        return domains
      end

      def find_spf_record(domain)
        spf_record = record_fetcher.txt_record_values(domain).each_with_object([]) {|txt_record_value, memo|
          memo << Coppertone::Record.new(txt_record_value) if Coppertone::Record.record?(txt_record_value)
        }

        case spf_record.length
        when 1 then
          return spf_record.first
        when 0 then
          raise SpfLookup::SpfRecordNotFound.new("#{domain} does not have an spf record.")
        else
          raise SpfLookup::MultipleSpfRecordError.new("There must be only one SPF record in the same domain.")
        end
      end

      def record_fetcher
        @fetcher ||= SPFRecordFetcher.new(SpfLookup::DNS_CONFIG[:option])
      end
    end
  end

end
