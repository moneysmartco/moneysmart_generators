require_relative "attribute/factory.rb"
require_relative "attribute.rb"
require_relative "url_builder.rb"
require_relative "yaml_parser.rb"
require_relative "../frontier.rb"

class ModelConfiguration

  attr_reader *[
    :attributes,
    :model_name,
    :namespaces,
    :skip_factory,
    :skip_model,
    :skip_policies,
    :skip_seeds,
    :skip_ui,
    :soft_delete,
    :url_builder
  ]

  def initialize(attributes)
    # Basic data about the model
    @model_name    = attributes.keys.first
    @namespaces    = attributes[@model_name][:namespaces] || []
    # TODO: Assert validity of attributes
    @attributes    = (attributes[@model_name][:attributes] || []).collect do |name, properties|
      ModelConfiguration::Attribute::Factory.build_attribute_or_association(self, name, properties)
    end

    # Configuration of generated items
    @skip_factory  = configuration_for(attributes[@model_name][:skip_factory])
    @skip_model    = configuration_for(attributes[@model_name][:skip_model])
    @skip_seeds    = configuration_for(attributes[@model_name][:skip_seeds])
    @skip_policies = configuration_for(attributes[@model_name][:skip_policies])
    parse_skip_ui_options(configuration_for(attributes[@model_name][:skip_ui]))
    @soft_delete   = configuration_for(attributes[@model_name][:soft_delete], default: true)

    # Additional utility items
    @url_builder = ModelConfiguration::UrlBuilder.new(self)
  end

  def as_constant
    "#{model_name.camelize}"
  end

  def as_symbol
    ":#{model_name}"
  end

  def as_symbol_collection
    ":#{model_name.pluralize}"
  end

  def as_title
    model_name.titleize
  end

  def ivar_collection
    "@#{model_name.pluralize}"
  end

  def ivar_instance
    "@#{model_name}"
  end

  # The primary attribute is used for:
  #   * Model#to_s (and spec)
  #   * Determining whether or not an instance of the model is visible in feature specs
  def primary_attribute
    attributes.find(&:is_primary?) || attributes.first
  end

  def skip_ui?
    skip_ui == true
  end

  def show_index?
    !@skip_index && !skip_ui?
  end

  def show_delete?
    !@skip_delete && !skip_ui?
  end

  def show_create?
    !@skip_create && !skip_ui?
  end

  def show_update?
    !@skip_update && !skip_ui?
  end

private

  def configuration_for(attribute, options={ default: false })
    attribute.nil? ? options[:default] : attribute
  end

  def parse_skip_ui_options(skip_ui_raw)
    if skip_ui_raw.is_a?(Array)
      @skip_index = skip_ui_raw.include?("index")
      @skip_delete = skip_ui_raw.include?("delete")
      @skip_create = skip_ui_raw.include?("create")
      @skip_update = skip_ui_raw.include?("update")
    else
      @skip_ui = skip_ui_raw
    end
  end
end
