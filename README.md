# Deprecated
## This project was abandonned and is not maintained anymore. For validation, see [jsonapi-parser](https://github.com/jsonapi-rb/parser). For deserialization, see [jsonapi-deserializable](https://github.com/jsonapi-rb/deserializable).

# jsonapi-validations
Ruby gem for validating [JSON API](http://jsonapi.org) payloads.

## Installation
```ruby
# In Gemfile
gem 'jsonapi-validations'
```
then
```
$ bundle
```
or manually via
```
$ gem install jsonapi-validations
```

## Usage

First, require the gem:
```ruby
require 'jsonapi/validations'
```
Then validate a resource creation/update payload:
```ruby
params = {
  permitted: {
    id: true,
    attributes: [:name, :address, :birthdate],
    relationships: [:posts, :sponsor]
  },
  required: {
    id: true,
    attributes: [:name, :address],
    relationships: [:sponsor]
  },
  types: {
    primary: [:users, :admins],
    relationships: {
      posts: {
        kind: :has_many,
        types: [:blogs, :posts]
      }
    }
  }
}
JSONAPI.validate_resource!(document_hash, params)
```
or a relationship update payload:
```ruby
params = {
  kind: :has_many,
  types: [:users, :admins]
}
JSONAPI.validate_relationship!(document_hash, params)
```

## License

jsonapi-validations is released under the [MIT License](http://www.opensource.org/licenses/MIT).
