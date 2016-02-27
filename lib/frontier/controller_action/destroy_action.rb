class Frontier::ControllerAction::DestroyAction

  attr_reader :model_configuration

  def initialize(model_configuration)
    @model_configuration = model_configuration
  end

  def to_s
    raw = <<-STRING
def new
  #{model_configuration.as_ivar_instance} = find_#{model_configuration.model_name}
  #{Frontier::Authorization::Assertion.new(model_configuration, :destroy).to_s}
  #{model_configuration.as_ivar_instance}.destroy

  respond_with(#{model_configuration.as_ivar_instance}, location: #{model_configuration.url_builder.index_path})
end
STRING
    raw.rstrip
  end

end
