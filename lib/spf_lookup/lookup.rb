require 'coppertone'
require_relative './txt_record_fetcher'
require_relative './spf_record'
require_relative './error'

module SpfLookup
  class Lookup

    class << self
      def run(domain)
        return dns_lookup(domain)
      end

      private

      def dns_lookup(domain)
        spf_record = find_spf_record(domain)

        includes = lookup_target_domains(spf_record).map {|_domain|
          dns_lookup(_domain)
        }

        return SpfRecord.new(
          domain,
          spf_record&.to_s,
          includes,
          spf_record&.dns_lookup_term_count
        )
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
        @fetcher ||= TXTRecordFetcher.new(SpfLookup::DNS_CONFIG[:option])
      end
    end
  end

end
