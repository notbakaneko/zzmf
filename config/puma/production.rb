# frozen_string_literal: true

workers Integer(ENV['ZZMF_PROCESSES'] || 4)
threads 4, 4

quiet
