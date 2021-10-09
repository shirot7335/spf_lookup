require 'coppertone'
require_relative './spf_record_fetcher'
require_relative './result'
require_relative './error'

module SpfLookup
  class DNSLookupCounter

    LOOKUP_LIMIT_SPECIFIED_BY_RFC7208 = 10

    class << self
      def count(domain)
        count_dns_lookup_0(domain)
      end

      def result(domain)
        return dns_lookup(domain)
      end

      def count_is_valid?(domain)
        return self.count(domain) <= LOOKUP_LIMIT_SPECIFIED_BY_RFC7208
      end

      private

      def dns_lookup(domain)
        spf_record = find_spf_record(domain)

        result = Result.new
        result.domain     = domain
        result.spf_record = spf_record.to_s
        result.lookup_term_count = spf_record&.dns_lookup_term_count || 0

        includes = lookup_target_domains(spf_record).map {|_domain|
          dns_lookup(_domain)
        }
        result.includes = includes

        return result
      end












      def count_dns_lookup_0(domain)
        return count_dns_lookup(domain, 0)
      end

      def count_dns_lookup(domain, count)
        spf_record = find_spf_record(domain)

        _count = lookup_target_domains(spf_record).inject(count) {|memo, _domain|
          memo = count_dns_lookup(_domain, memo)
        }

        return _count + (spf_record&.dns_lookup_term_count || 0)
      end

      def lookup_target_domains(spf_record)
        return [] if spf_record.blank?

        domain_fetcher = -> (obj) { obj.domain_spec.macro_text }

        domains = spf_record.includes.each_with_object([]) { |include_value, memo|
          memo << domain_fetcher.(include_value.mechanism)
        }
        domains << domain_fetcher.(spf_record.redirect) unless spf_record.redirect.nil?

        return domains.compact
      end

      def find_spf_record(domain)
        spf_record = record_fetcher.txt_record_values(domain).each_with_object([]) {|txt_record_value, memo|
          memo << Coppertone::Record.new(txt_record_value) if Coppertone::Record.record?(txt_record_value)
        }

        if spf_record.length > 1
          raise SpfLookup::MultipleSpfRecordError.new("There must be only one SPF record in the same domain.")
        end

        return spf_record.first
      end

      def record_fetcher
        @fetcher ||= SPFRecordFetcher.new(SpfLookup::DNS_CONFIG[:option])
      end
    end
  end

end
