# All of the publisher details schemas used as input
details_schemas := $(wildcard formats/*/publisher/details.json)

# All of the example files
examples := $(wildcard formats/*/frontend/examples/*.json)

# Derive the publisher schema files from the details schemas by substitution
publisher_schemas := $(details_schemas:details.json=schema.json)

# Derive the frontend schemas from the details schemas by substitution
frontend_schemas := $(details_schemas:publisher/details.json=frontend/schema.json)

# The validation records are temporary files which are created to indicate that a given
# example has been validated.
validation_records := $(examples:.json=.json.valid)

# The various scripts used in the build process
combiner_bin := bundle exec ./bin/combine_publisher_schema
frontend_generator_bin := bundle exec ./bin/generate_frontend_schema
validation_bin := bundle exec ./bin/validate
ensure_example_base_paths_unique_bin := bundle exec ./bin/ensure_example_base_paths_unique

# The tasks run as part of the default make process
default: $(publisher_schemas) $(frontend_schemas) validate_unique_base_path $(validation_records)

# A task to remove all intermediary files and force a complete rebuild
clean:
	rm -f $(validation_records)
	rm -f $(frontend_schemas)
	rm -f $(publisher_schemas)

validate_unique_base_path: $(frontend_schemas)
	$(ensure_example_base_paths_unique_bin) $(examples)

# Recipe for building publisher schemas from the metadata, details and links schemas
%/publisher/schema.json: %/../metadata.json %/publisher/details.json $(wildcard %/publisher/links.json)
	$(combiner_bin) ${@:schema.json=} ${@}

# Recipe for building the frontend schema from the publisher schema and frontend links definition
%/frontend/schema.json: %/publisher/schema.json %/../frontend_links_definition.json
	$(frontend_generator_bin) -f ${@:frontend/schema.json=../frontend_links_definition.json} ${@:frontend/schema.json=publisher/schema.json} > ${@}

# Recipe for validating frontend examples (the build target is the `.valid` file)
%.valid: $(frontend_schemas) %
	$(validation_bin) ${@:.valid=} && touch ${@}
