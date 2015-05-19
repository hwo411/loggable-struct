# loggable-struct
Implementation of loggable struct using Ruby refinements

### Usage
Require the basic file `loggable_struct` somewhere:
```ruby
require "loggable_struct"
```

And then add to module where you want to have logging:
```ruby
using LoggableStruct
```

### Simple example (using pry or irb)
```ruby
require_relative "lib/loggable_struct"

SomeStruct = Struct.new :foo, :bar
struct1 = SomeStruct.new foo: 1

begin
  using LoggableStruct
  
  SomeStruct.new.foo
  struct1.foo
end
```

Output:
```
I, [2015-05-19T11:50:22.000680 #53964]  INFO -- : :foo
I, [2015-05-19T11:50:22.000790 #53964]  INFO -- : :foo
```

### Notes:
There are few implementation limitations due to refinements implementation:
 - As I mentioned above, monkey patching objects is not supported;
 - If you create a new `Struct` class(not object) inside the block where `using LoggableStruct` was used, it’s instances will not have their new methods logged.

Both cases are described in specs.

There are few things to mention:
- I tried a few AOP gems and found no one working correctly with refinements; 
- Creating `Struct` descendants does not call inherited method, so I was unable to track descendants this way; 
- It still requires monkey-patching for Struct outside of the refinement to track its descendants and their methods;
- Even refinement creates a module, this module doesn’t call neither `included` nor `extended` when `using` is called;
- Using `ObjectSpace.each_object` allows using this refinement even if `loggable_struct` and `core_ext/struct` were included far from the start of the application(e.g. in the middle of the irb or pry session), also it was the cheapest way to track all existing descendants of `Struct` due to all these limitations.
