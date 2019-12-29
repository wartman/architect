package modules;

import architect.Module;
import services.FooService;

@:module(
  providers = [ FooService ],
  exports = [ FooService ]
)
class SimpleModule implements Module {}
