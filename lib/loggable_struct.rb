require "logger"
require_relative "core_ext/struct"

module LoggableStruct
  Logger = ::Logger.new(STDOUT)

  def self.refine_with_logging(klass, method_name)
    refine klass do
      method = instance_method(method_name)

      define_method(method_name) do |*args|
        LoggableStruct::Logger.info method_name
        method.bind(self).call(*args)
      end
    end
  end
end

ObjectSpace.each_object(Class).select { |klass| klass <= Struct }.each do |klass|
  methods = klass.instance_methods + klass.private_instance_methods
  methods.each { |method_name| LoggableStruct.refine_with_logging(klass, method_name) }
end
