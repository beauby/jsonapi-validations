require 'jsonapi/validations/relationship'
require 'jsonapi/validations/resource'

module JSONAPI
  module_function

  def validate_resource!(document, params = {})
    Validations::Resource.validate!(document, params)
  end

  def validate_relationship!(document, params = {})
    Validations::Relationship.validate!(document, params)
  end
end
