# frozen_string_literal: true

workers Integer(ENV['ZZMF_PROCESSES'] || 2)
threads 4, 4
