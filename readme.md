Architect
=========

Architecture for Haxe projects, built on Capsule

Usage
-----

Architect modules look like this:

```haxe
import architect.Module;

@:module(
  imports = [
    BinModule
  ],
  exports = [
    @:tag('foo') String,
    @:tag('bin') String, // From BinModule
    @:tag('bar') String, // from BarServiceProvider 
    SomeService,
    SomeInterface
  ],
  // Classes or more complex mappings go here: 
  mappings = [
    SomeService // Automatically maps to a class
    SomeInterface => SomeService // ... or you can map to an interface/subclass
    @:tag('foo') ( String => @:toValue 'foo' ) // ... or to a simple value
  ],
  // Any capsule.ServiceProvider goes here:
  providers = [
    BarServiceProvider
  ]
)
class ExampleModule implements Module {}

```

Ideally this will allow modules to be statically analyzable and to give useful errors at compile time.

> more soon
