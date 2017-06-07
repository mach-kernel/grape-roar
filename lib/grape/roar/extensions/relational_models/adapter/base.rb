module Grape
  module Roar
    module Extensions
      module RelationalModels
        module Adapter
          class Base
            class << self
              def valid_for?(klass)
                valid_proc.(klass) rescue nil
              end

              def valid_for(&block)
                @valid_proc = block
              end

              private

              attr_reader :valid_proc
            end

            def initialize(klass)
              @klass = klass
            end

            def collection_methods
              raise NotImplementedError
            end

            def single_entity_methods
              raise NotImplementedError
            end

            private

            attr_reader :klass
          end
        end
      end
    end
  end
end