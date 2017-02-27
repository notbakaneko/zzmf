# frozen_string_literal: true

module RequestValidators
  module Basic
    private

    def validate!(request)
      # rubocop:disable Metrics/LineLength, Style/NumericPredicate
      # arbitrary
      raise ArgumentError, 'l must be > 0 and < 10000' unless request.params['l'] && request.params['l'].to_i > 0 && request.params['l'].to_i < 10_000
      raise ArgumentError, 'q must be >=0 and <= 100' unless request.params['q'] && request.params['q'].to_i >= 0 && request.params['q'].to_i <= 100
      raise ArgumentError, 's must be >=1 and <= 2' if request.params['s'] && request.params['s'].to_f < 1 && request.params['s'].to_f > 2
      rause ArgumentError, 'A filename is required' unless request.path_info && !request.path_info.empty?
      # rubocop:enable Metrics/LineLength, Style/NumericPredicate
    end
  end
end
