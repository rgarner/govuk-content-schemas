require 'govuk_content_schemas'
require 'thin'
require 'pathname'
require 'json'

class GovukContentSchemas::ContentItemExampleApp
  attr_reader :formats_path

  def initialize(formats_path)
    @formats_path = Pathname.new(formats_path)
  end

  def examples
    @examples ||= load_examples
  end

  def call(env)
    example = find_example(env)
    if example
      present_example(example)
    else
      present_not_found
    end
  end

  def find_example(env)
    path = env["PATH_INFO"]
    examples[path]
  end

private
  def present_example(example)
    headers = {
      'Content-Type' => 'application/json; charset=utf-8',
      'Content-Length' => example.raw_data.bytesize.to_s,
      'Cache-control' => 'no-cache'
    }

    [200, headers, [example.raw_data]]
  end

  def present_not_found
    body = 'Not found'
    headers = {
      'Content-Type' => 'text/plain',
      'Content-Length' => body.size.to_s,
      'Cache-control' => 'no-cache'
    }
    [404, headers, [body]]
  end

  def all_example_paths
    Dir[formats_path + "*" + "frontend" + "examples" + "*.json"]
  end

  def all_examples
    all_example_paths.map { |path| Example.new(path) }
  end

  def load_examples
    all_examples.inject({}) do |hash, example|
      hash.merge(example.base_path => example)
    end
  end

  class Example
    attr_reader :path

    def initialize(path)
      @path = path
    end

    def base_path
      data["base_path"]
    end

    def data
      JSON.parse(raw_data)
    end

    def raw_data
      File.read(path)
    end
  end
end
