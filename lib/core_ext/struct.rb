# Monkey patch for Struct
# Tracks method adding and patches every method in LoggableStruct refinement
class Struct
  def self.method_added(name)
    return if @_adding

    begin
      @_adding = true
      ::LoggableStruct.refine_with_logging(self, name)
    ensure
      @_adding = false
    end
  end
end
