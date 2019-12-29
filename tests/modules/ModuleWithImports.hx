package modules;

import architect.Module;
import services.*;

@:module(
  imports = [ 
    SimpleModule,
    ModuleWithServiceProvider
  ],
  providers = [ FooBarService ],
  exports = [ 
    FooBarService,
    FooService,
    @:tag('foo') String
  ]
)
class ModuleWithImports implements Module {}
