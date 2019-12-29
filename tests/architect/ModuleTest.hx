package architect;

import services.*;
import modules.*;

using medic.Assert;

class ModuleTest {

  public function new() {}

  @test('Simple module works')
  public function testSimple() {
    var module = new SimpleModule();
    module.build().get(FooService).getFoo().equals('foo');
  }

  @test('Modules can import other modules')
  public function testBasicImports() {
    var module = new ModuleWithImports();
    var container = module.build();
    container.has(FooService).isTrue();
    container.has(FooBarService).isTrue();
    container.get(FooBarService).getFooBar().equals('foo bar');
    container.get(String, 'foo').equals('foo');
  }

  @test('Modules map ServiceProviders correctly')
  public function testServiceProvider() {
    var module = new ModuleWithServiceProvider();
    var container = module.build();
    container.get(String, 'foo').equals('foo');
  }

}
