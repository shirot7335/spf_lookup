module SpfLookup
  class Error < StandardError
  end

  class SpfRecordNotFound < Error
  end

  class MultipleSpfRecordError < Error
  end
end
