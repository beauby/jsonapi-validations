require 'jsonapi/parser'

module JSONAPI
  module Validations
    module Resource
      module_function

      # Validate the structure of a resource create/update payload. Optionally
      #   validate whitelisted/required id/attributes/relationships, as well as
      #   primary type and relationship types.
      #
      # @param [Hash] document The input JSONAPI document.
      # @param [Hash] params Validation parameters.
      #   @option [Hash] permitted Permitted attributes/relationships/primary
      #     id. Optional. If not supplied, all legitimate fields are permitted.
      #   @option [Hash] required Required attributes/relationships/primary id.
      #     Optional. The fields must be explicitly permitted, or permitted
      #     should not be provided.
      #   @option [Hash] types Permitted primary/relationships types. Optional.
      #     The relationships must be explicitly permitted. Not all
      #     relationships' types have to be specified.
      # @raise [JSONAPI::Parser::InvalidDocument] if document is invalid.
      #
      # @example
      #   params = {
      #     permitted: {
      #       id: true, # Simply ommit it to forbid it.
      #       attributes: [:title, :date],
      #       relationships: [:comments, :author]
      #     },
      #     required: {
      #       id: true,
      #       attributes: [:title],
      #       relationships: [:comments, :author]
      #     },
      #     types: {
      #       primary: [:posts],
      #       relationships: {
      #         comments: {
      #           kind: :has_many,
      #           types: [:comments]
      #         },
      #         author: {
      #           kind: :has_one,
      #           types: [:users, :superusers]
      #         }
      #       }
      #     }
      #   }
      def validate!(document, params = {})
        JSONAPI.parse_resource!(document)

        validate_permitted!(document['data'], params[:permitted])
        validate_required!(document['data'], params[:required])
        validate_types!(document['data'], params[:types])
      end

      # @api private
      def validate_permitted!(data, permitted)
        return if permitted.nil?
        unless permitted[:id] || !data.key?('id')
          raise JSONAPI::Parser::InvalidDocument,
                'Unpermitted id.'
        end
        # TODO(beauby): Handle meta (and possibly links) once the spec has
        #   been clarified.
        permitted_attrs = permitted[:attributes] || []
        if data.key?('attributes')
          data['attributes'].keys.each do |attr|
            unless permitted_attrs.include?(attr.to_sym)
              raise JSONAPI::Parser::InvalidDocument,
                    "Unpermitted attribute #{attr}"
            end
          end
        end
        permitted_rels = permitted[:relationships] || []
        return unless  data.key?('relationships')
        data['relationships'].keys.each do |rel|
          next if permitted_rels.include?(rel.to_sym)
          raise JSONAPI::Parser::InvalidDocument
        end
      end

      # @api private
      def validate_required!(data, required)
        return if required.nil?
        unless data.key?('id') || !required[:id]
          raise JSONAPI::Parser::InvalidDocument, 'Missing required id.'
        end
        # TODO(beauby): Same as for permitted.

        unless data.key?('attributes') || !required[:attributes]
          raise JSONAPI::Parser::InvalidDocument, 'Missing required attributes.'
        end
        required[:attributes].each do |attr|
          next if data['attributes'][attr.to_s]
          raise JSONAPI::Parser::InvalidDocument,
                "Missing required attribute #{attr}."
        end
        unless data.key?('relationships') || !required[:relationships]
          raise JSONAPI::Parser::InvalidDocument,
                'Missing required relationships.'
        end
        required[:relationships].each do |rel|
          unless data['relationships'][rel.to_s]
            raise JSONAPI::Parser::InvalidDocument,
                  "Missing required relationship #{rel}."
          end
        end
      end

      # @api private
      def validate_types!(data, types)
        return if types.nil?
        unless !types[:primary] || types[:primary].include?(data['type'].to_sym)
          raise JSONAPI::Parser::InvalidDocument,
                "Type mismatch for resource: #{data['type']} " \
                "should be one of #{types[:primary]}"
        end
        return unless data.key?('relationships') && types.key?(:relationships)
        types[:relationships].each do |key, rel_types|
          rel = data['relationships'][key.to_s]
          next unless rel
          Relationship.validate_types!(rel, rel_types, key)
        end
      end
    end
  end
end
