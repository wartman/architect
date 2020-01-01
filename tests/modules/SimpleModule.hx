package modules;

import architect.Module;
import services.FooService;

@:module(
  mappings = [ FooService ],
  exports = [ FooService ]
)
class SimpleModule implements Module {}
