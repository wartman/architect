package services;

import capsule.Container;
import capsule.ServiceProvider;

class SimpleServiceProvider implements ServiceProvider {
  
  final foo:String;

  public function new(foo) {
    this.foo = foo;
  }

  public function register(container:Container) {
    container.map(String, 'foo').toValue(foo);
  }

}
