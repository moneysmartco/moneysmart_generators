class Frontier::Attribute

  attr_reader :model, :is_primary, :name, :properties

  def initialize(model, name, properties)
    @model = model
    @name = name.to_s
    @properties = properties
    @is_primary = @properties[:primary] == true
  end

  # some_thing -> "Some thing"
  def capitalized
    name.titleize.capitalize
  end

  def constants
    validations.collect(&:corresponding_constant).compact
  end

  def as_table_heading
    name.titleize
  end

  # some_thing -> ":some_thing"
  def as_field_name
    as_symbol
  end

  def as_symbol
    ":#{name}"
  end

  def is_primary?
    !!@is_primary
  end

  def sortable?
    properties[:sortable]
  end

  def type
    properties[:type].to_s
  end

# Views

  # TODO: Break this out into own class
  def as_enum
    # Should look like:
    #   enum attribute_name: ["one", "two"]

    if is_enum?
      if (enum_options = properties[:enum_options]).present?
        enum_options_as_hash = Frontier::HashSingleLineDecorator.new array_as_hash(enum_options)
        "enum #{name}: {#{enum_options_as_hash}}"
      else
        raise(ArgumentError, "No enum_options provided for attribute: #{name}")
      end
    else
      raise(ArgumentError, "Attempting to display field #{name} as enum, but is #{type}")
    end
  end

  def is_enum?
    properties[:type] == "enum"
  end

  def show_on_form?
    properties[:show_on_form].nil? || properties[:show_on_form]
  end

  def show_on_index?
    properties[:show_on_index].nil? || properties[:show_on_index]
  end

  # index refers to the index.html.haml template, nothing to do with DB.
  def as_index_string
    case type
      when "text" then "truncate(#{model.name.as_singular}.#{name}, length: 30)"
      else "#{model.name.as_singular}.#{name}"
    end
  end

# Models

  def is_attribute?
    !is_association?
  end

  def is_association?
    false
  end

  def validations
    @validations ||= (properties[:validates] || []).collect do |key, args|
      Frontier::Attribute::Validation::Factory.new.build(self, key, args)
    end
  end

  def validation_implementation
    validation_string = validations.collect(&:as_implementation).join(", ")
    "validates #{as_symbol}, #{validation_string}"
  end

  def validation_required?
    validations.any?
  end

# Factories

  def as_factory_declaration
    Frontier::Attribute::FactoryDeclaration.new(self).to_s
  end

# Migrations

  def as_migration_component
    Frontier::Attribute::MigrationComponent.new(self).to_s
  end

private

  def array_as_hash(array)
    Hash[array.zip(0..array.length)]
  end
end

require_relative "attribute/constant.rb"
require_relative "attribute/factory.rb"
require_relative "attribute/factory_declaration.rb"
require_relative "attribute/feature_spec_assignment.rb"
require_relative "attribute/migration_component.rb"
require_relative "attribute/validation.rb"
