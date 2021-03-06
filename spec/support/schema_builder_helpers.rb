require 'pathname'
require 'json-schema'

module SchemaBuilderHelpers
  def project_root
    Pathname.new(File.expand_path("../../", __dir__))
  end

  def build_schema(name, properties: nil, definitions: nil, required: nil, oneOf: nil)
    schema = {
      "$schema" => "http://json-schema.org/draft-04/schema#",
      "type" => "object"
    }
    schema['properties'] = properties if properties
    schema['definitions'] = definitions if definitions
    schema['required'] = required if required
    schema['oneOf'] = oneOf if oneOf
    JSON::Schema.new(schema, URI.parse(name))
  end

  def build_string_properties(*properties)
    properties.inject({}) do |memo, property_name|
      memo.merge(property_name => {"type" => "string"})
    end
  end

  def build_ref_properties(property_names, refname)
    property_names.inject({}) do |memo, property_name|
      memo.merge(property_name => {
        "$ref" => "#/definitions/#{refname}"
      })
    end
  end

  def build_publisher_schema(properties, link_names = nil, required_properties = nil)
    properties = build_string_properties(*properties)
    properties['links'] = build_publisher_links_schema(*link_names) if link_names
    definitions = build_string_properties('guid_list')
    build_schema('schema.json', oneOf: [{'properties' => properties, 'required' => required_properties}], definitions: definitions)
  end

  def build_publisher_links_schema(*link_names)
    {
      "type" => "object",
      "additionalProperties" => false,
      "properties" => build_ref_properties(link_names, "guid_list")
    }
  end

  def build_frontend_links_schema(*link_names)
    {
      "type" => "object",
      "additionalProperties" => false,
      "properties" => build_ref_properties(link_names, "frontend_links")
    }
  end

  def slice_hash(hash, *keys)
    keys.each_with_object({}) { |k, h| h[k] = hash[k] if hash.has_key?(k) }
  end
end
