require 'jsonapi/parser'

module JSONAPI
  module Validations
    module Relationship
      module_function

      # Validate the types of related objects in a relationship update payload.
      #
      # @param [Hash] document The input JSONAPI document.
      # @param [Hash] params Validation parameters.
      #   @option [Symbol] kind Whether it is a :has_many or :has_one.
      #   @option [Array<Symbol>] types Permitted types for the relationship.
      # @raise [JSONAPI::Parser::InvalidDocument] if document is invalid.
      def validate_relationship!(document, params = {})
        JSONAPI.parse_relationship!(document)
        validate_types!(document['data'], params[:types])
      end

      # @api private
      def validate_types!(rel, rel_types, key = nil)
        rel_name = key ? " #{key}" : ''
        if rel_types[:kind] == :has_many
          unless rel['data'].is_a?(Array)
            raise JSONAPI::Parser::InvalidDocument,
                  "Expected relationship#{rel_name} to be has_many."
          end
          return unless rel_types[:types]
          rel['data'].each do |ri|
            next if rel_types[:types].include?(ri['type'].to_sym)
            raise JSONAPI::Parser::InvalidDocument,
                  "Type mismatch for relationship#{rel_name}: " \
                  "#{ri['type']} should be one of #{rel_types}"
          end
        else
          return if rel['data'].nil?
          unless rel['data'].is_a?(Hash)
            raise JSONAPI::Parser::InvalidDocument,
                  "Expected relationship#{rel_name} to be has_one."
          end
          return unless rel_types[:types]
          ri = rel['data']
          return if rel_types[:types].include?(ri['type'].to_sym)
          raise JSONAPI::Parser::InvalidDocument,
                "Type mismatch for relationship#{rel_name}: " \
                "#{ri['type']} should be one of #{rel_types}"
        end
      end
    end
  end
end
