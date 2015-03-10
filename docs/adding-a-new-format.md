# Adding a new content format

There is a rake task that will help get you started:

```
  $ rake new_format[FORMAT_NAME]
```

This will create the basic folder structure and files needed for a new format
schema:

```
  formats/FORMAT_NAME/frontend
  formats/FORMAT_NAME/frontend/examples
  formats/FORMAT_NAME/publisher
  formats/FORMAT_NAME/publisher/details.json
  formats/FORMAT_NAME/publisher/links.json
```

The schema will be generated from the `details.json` and `links.json` files.
Complete these files with the necessary fields for your new format. Once you
have completed these files, you can generate the corresponding frontend and
publisher `schema.json` with the [`make` task](../README.md##makefile).

## Examples

Any new format should also ship with a set of curated examples. These examples
will be validated against the schema and can also be used by the corresponding
frontend applications to verify that it can render examples of the format. These
examples should be added to the `formats/FORMAT_NAME/frontend/examples` folder.