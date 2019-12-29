package modules;

import architect.Module;
import services.*;

@:module(
  providers = [ new SimpleServiceProvider('foo') ],
  exports = [ @:tag('foo') String ]
)
class ModuleWithServiceProvider implements Module {}
