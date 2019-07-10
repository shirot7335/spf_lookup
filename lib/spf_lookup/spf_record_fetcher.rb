require 'resolv'

class SPFRecordFetcher
  def initialize(resolver = Resolv::DNS.new)
    @resolver = resolver
  end

  def txt_record_values(domain)
    begin
      return txt_record_resources(domain).collect { |resource|
        resource.strings
      }
    rescue => e
      "Error: #{e}"
    end
  end

  def txt_record_resources(domain)
    return record_resources(domain, 'TXT')
  end

  def record_resources(domain, record_type)
    return @resolver.getresources(domain, type_class(record_type))
  end

  private

  SUPPORTED_TYPE_CLASS = %w[TXT].freeze
  def type_class(record_type)
    raise ArgumentError unless SUPPORTED_TYPE_CLASS.include?(record_type.upcase)
    Resolv::DNS::Resource::IN.const_get(record_type.upcase)
  end

end
