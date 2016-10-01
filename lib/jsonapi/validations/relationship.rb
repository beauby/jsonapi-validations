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
      # @raise [JSONAPI::Validator::InvalidDocument] if document is invalid.
      def validate_relationship!(document, params = {})
        JSONAPI.parse_relationship!(document)
        validate_types!(document['data'], params[:types])
      end

      # @api private
      def validate_types!(rel, rel_types, key = nil)
        rel_name = key ? " #{key}" : ''
        if rel_types[:kind] == :has_many
          Document.ensure!(rel['data'].is_a?(Array),
                           "Expected relationship#{rel_name} to be has_many.")
          return unless rel_types[:types]
          rel['data'].each do |ri|
            Document.ensure!(rel_types[:types].include?(ri['type'].to_sym),
                             "Type mismatch for relationship#{rel_name}: " \
                             "#{ri['type']} should be one of #{rel_types}")
          end
        else
          return if rel['data'].nil?
          Document.ensure!(rel['data'].is_a?(Hash),
                           "Expected relationship#{rel_name} to be has_one.")
          return unless rel_types[:types]
          ri = rel['data']
          Document.ensure!(rel_types[:types].include?(ri['type'].to_sym),
                           "Type mismatch for relationship#{rel_name}: " \
                           "#{ri['type']} should be one of #{rel_types}")
        end
      end
    end
  end
end
