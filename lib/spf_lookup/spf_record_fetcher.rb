require 'resolv'


module SpfLookup
  class SPFRecordFetcher

    SUPPORTED_TYPE_CLASS = %w[TXT].freeze

    def initialize(dns_conf = nil)
      @resolver = Resolv::DNS.new(dns_conf)
    end

    def txt_record_values(domain)
      return txt_record_resources(domain).collect { |resource| resource.strings }
    end

    def txt_record_resources(domain)
      return record_resources(domain, 'TXT')
    end

    def record_resources(domain, record_type)
      resources = @resolver.getresources(domain, type_class(record_type))
      raise Resolv::ResolvError, "Could not lookup '#{domain}'." if resources.empty?
      return resources
    end

    private
    def type_class(record_type)
      raise ArgumentError unless SUPPORTED_TYPE_CLASS.include?(record_type.upcase)
      Resolv::DNS::Resource::IN.const_get(record_type.upcase)
    end

  end
end
