package architect;

#if !macro

import capsule.Container;
import capsule.ServiceProvider;

@:autoBuild(architect.Module.build())
interface Module {
  public function __exportInto(child:Container):Void;
  public function build():Container;
}

#else

// TODO:
// Actually track exports and imports, and warn at compile-time if
// a module requires something that isn't provided.
//
// Not 100% sure how to do that yet, but that'll be the best feature of
// this thing.
//
// Also: allow modules to be passed in as instances! Will allow some configuration.

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type.ClassType;

class Module {
  
  public static function build() {
    return new Module(
      Context.getLocalClass().get(),
      Context.getBuildFields()
    ).export();
  }

  final cls:ClassType;
  final fields:Array<Field>;

  public function new(cls, fields) {
    this.cls = cls;
    this.fields = fields;
  }

  public function export():Array<Field> {
    var meta = cls.meta.extract(':module');
    var params:Array<Expr> = [];

    switch meta {
      case []: 
        Context.error('An `@:module` meta is required for all modules', cls.pos);
      case [ { params: p } ]:
        params = p;
      default:
        Context.error('Only one `@:module` declaration is allowed per module', meta[meta.length - 1].pos);
    }

    var imports:Array<Expr> = [];
    var exports:Array<Expr> = [];
    var mappings:Array<Expr> = [];
    var hasNew:Bool = false;

    for (f in fields) switch f.kind {
      case FFun(_) if (f.name == 'new'): hasNew = true;
      default:
    }

    if (hasNew == false) {
      fields.push((macro class {
        public function new() {}
      }).fields[0]);
    }

    for (param in params) switch param {

      case macro imports = ${e}: switch e.expr {
        case EArrayDecl(decls):
          for (decl in decls) {
            imports.push(macro container.build(${decl}).__exportInto(container));
          }
        default:
          Context.error('Invalid expression for imports', e.pos);
      }

      case macro mappings = ${e}:
        function add(decl:Expr, tag:Expr) {
          decl = switch decl {
            case macro ( ${decl} ): decl;
            default: decl;
          }
          switch decl {
            case macro ${decl} => ${factory}: switch factory {
              case macro @:toValue ${value}:
                mappings.push(macro @:pos(decl.pos) container.map(${decl}, ${tag}).toValue(${value}));
              case macro @:toFactory ${factory}:
                mappings.push(macro @:pos(decl.pos) container.map(${decl}, ${tag}).toFactory(${factory}).asShared());
              default:
                mappings.push(macro @:pos(decl.pos) container.map(${decl}, ${tag}).toClass(${factory}).asShared());
            }
            default:
              mappings.push(macro @:pos(decl.pos) container.map(${decl}, ${tag}).toClass(${decl}).asShared());
          }
        }

        switch e.expr {
          case EArrayDecl(decls):
            for (decl in decls) switch decl {
              case macro @:tag(${tag}) ${def}: add(def, tag);
              default: add(decl, macro null); 
            }
          default:
            Context.error('Invalid expression for mappings', e.pos);
        }

      case macro providers = ${e}:
        function add(decl:Expr) {
          mappings.push(macro @:pos(decl.pos) container.use(${decl}));
        }

        switch e.expr {
          case EArrayDecl(decls):
            for (decl in decls) add(decl);
          default:
            Context.error('Invalid expression for providers', e.pos);
        }

      case macro exports = ${e}:
        function add(decl:Expr, tag:Expr) {
          exports.push(macro child.map(${decl}, ${tag}).toFactory(() -> {
            return self.get(${decl}, ${tag});
          }).asShared());
        }
        switch e.expr {
          case EArrayDecl(decls):
            for (decl in decls) switch decl {
              case macro @:tag(${tag}) ${def}: add(def, tag);
              default: add(decl, macro null);
            }
          default:
            Context.error('Invalid expression for exports', e.pos);
        }

      default:
        Context.error('Invalid expression', param.pos);
    }

    return fields.concat((macro class {
    
      var __c:capsule.Container;
      
      public function __exportInto(child:capsule.Container) {
        var self = build();
        $b{exports};
      }

      public function build() {
        if (__c != null) return __c;
        var container = new capsule.Container();
        $b{mappings};
        $b{imports};
        __c = container;
        return container;
      }

    }).fields);
  }

}

#end
