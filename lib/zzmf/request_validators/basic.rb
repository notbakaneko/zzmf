# frozen_string_literal: true

module Zzmf
  module RequestValidators
    module Basic
      private

      def validate!(request) # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity
        # arbitrary
        if request.params['w'] || request.params['h']
          raise ArgumentError, 'w must be > 0 and <= 25000' unless request.params['w'] &&
                                                                   request.params['w'].to_i > 0 &&
                                                                   request.params['w'].to_i <= 25_000

          raise ArgumentError, 'h must be > 0 and <= 25000' unless request.params['h'] &&
                                                                   request.params['h'].to_i > 0 &&
                                                                   request.params['h'].to_i <= 25_000
        else
          raise ArgumentError, 'l must be > 0 and <= 25000' unless request.params['l'] &&
                                                                   request.params['l'].to_i > 0 &&
                                                                   request.params['l'].to_i <= 25_000
        end
        raise ArgumentError, 'q must be >=0 and <= 100' unless request.params['q'] &&
                                                               request.params['q'].to_i >= 0 &&
                                                               request.params['q'].to_i <= 100

        raise ArgumentError, 's must be >=1 and <= 2' if request.params['s'] &&
                                                         request.params['s'].to_f < 1 &&
                                                         request.params['s'].to_f > 2

        raise ArgumentError, 'A filename is required' unless request.path_info &&
                                                             !request.path_info.empty?
      end
    end
  end
end
