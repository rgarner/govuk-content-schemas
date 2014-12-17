require 'govuk_content_schemas/frontend_schema_generator'

RSpec.describe GovukContentSchemas::FrontendSchemaGenerator do
  include GovukContentSchemas::Utils

  let(:publisher_properties) {
    %w{
      base_path
      content_id
      description
      details
      format
      locale
      need_ids
      public_updated_at
      publishing_app
      redirects
      rendering_app
      routes
      title
      update_type
    }
  }

  let(:link_names) { ["lead_organisations"] }

  let(:required_properties) {
    %w{
      base_path
      format
      locale
      publishing_app
      update_type
    }
  }

  let(:publisher_schema) {
    build_publisher_schema(publisher_properties, link_names, required_properties)
  }

  subject(:generated) {
    described_class.new(publisher_schema).generate
  }

  let(:internal_properties) {
    %w{content_id publishing_app redirects rendering_app routes update_type}
  }

  it "does not modify its input" do
    original = Marshal.load(Marshal.dump(publisher_schema))

    generated

    expect(publisher_schema.schema).to eq(original.schema)
  end

  it "removes internal properties from the top level properties list" do
    internal_properties.each do |internal_property|
      expect(generated.schema['properties'].keys).to_not include(internal_property)
    end
  end

  it "removes internal properties from the top level list of required properties" do
    internal_properties.each do |internal_property|
      expect(generated.schema['required']).to_not include(internal_property)
    end
  end

  it "adds updated_at as an allowed datetime property" do
    expect(generated.schema['properties']).to include(
      "updated_at" => {
        "type" => "string",
        "format" => "date-time"
      }
    )
  end

  it "injects a frontend_links definition" do
    expect(generated.schema['definitions']).to include('frontend_links')
    expect(generated.schema['definitions']['frontend_links']['type']).to eq('array')
  end

  it "transforms the links specification to allow expanded links and available_tranlsations" do
    expect(generated.schema['properties']['links']).to eq(build_frontend_links_schema(*link_names, 'available_translations'))
  end

  context "publisher schema specifies a required link" do
    let(:publisher_schema_with_required_link) {
      clone_schema(publisher_schema).tap do |cloned|
        cloned.schema['properties']['links']['required'] = link_names
      end
    }

    subject(:generated) {
      described_class.new(publisher_schema_with_required_link).generate
    }

    it "preserves list of required items" do
      expect(generated.schema['properties']['links']['required']).to eq(link_names)
    end
  end

  context "no links in publisher schema" do
    let(:link_names) { nil }

    it "transforms the links specification to allow available_tranlsations" do
      expect(generated.schema['properties']['links']).to eq(build_frontend_links_schema('available_translations'))
    end
  end
end
