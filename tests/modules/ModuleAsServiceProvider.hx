package modules;

import capsule.Container;
import architect.Module;

@:module(
  exports = [ @:tag('foo') String ]
)
class ModuleAsServiceProvider implements Module {

  final foo:String;

  public function new(foo) {
    this.foo = foo;
  }

  public function register(container:Container) {
    container.map(String, 'foo').toValue(foo);
  }

}
