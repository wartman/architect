package modules;

import capsule.Container;
import architect.Module;
import services.*;

@:module(
  exports = [ 
    String,
    @:tag('foo') String,
    StringService
  ],
  mappings = [
    String => @:toFactory function (@:inject.tag('target') target:String) return 'no ${target}',
    @:tag('foo') ( String => @:toValue this.foo ),
    @:tag('target') ( String => @:toValue 'tag' ),
    StringService => @:toValue new StringService('bar')
  ]
)
class ModuleWithSpecificMappings implements Module {

  final foo:String;

  public function new(foo) {
    this.foo = foo;
  }

}
