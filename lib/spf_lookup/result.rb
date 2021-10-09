module SpfLookup
  class Result
    attr_accessor :domain, :spf_record, :includes
    attr_accessor :lookup_term_count

    def initialize
      @domain     = ""
      @spf_record = ""
      @includes   = []
      @lookup_term_count = 0
    end

    def lookup_count
      return count_dns_lookup_0
    end

    def to_hash
      return {
        domain:     @domain,
        spf_record: @spf_record,
        includes:   includes_to_hash,
        lookup_term_count: @lookup_term_count
      }
    end

    def to_json
      return self.to_hash.to_json
    end

    private

    def count_dns_lookup_0
      return count_dns_lookup(self, 0)
    end

    def count_dns_lookup(result, count)
      _count = result.includes.inject(count) {|memo, r|
        memo = count_dns_lookup(r, memo)
      }

      return _count + result.lookup_term_count
    end

    def includes_to_hash
      return includes.map {|result|
        result.to_hash
      }
    end
  end

end
