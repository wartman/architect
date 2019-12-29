package architect;

#if !macro

import capsule.Container;

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
    var providers:Array<Expr> = [];
    var exports:Array<Expr> = [];

    for (param in params) switch param {

      case macro imports = ${e}: switch e.expr {
        case EArrayDecl(decls):
          for (decl in decls) {
            imports.push(macro container.build(${decl}).__exportInto(container));
          }
        default:
          Context.error('Invalid expression for imports', e.pos);
      }

      case macro providers = ${e}:
        function add(decl:Expr, tag:Expr) {
          if (Context.unify(Context.typeof(decl), Context.getType('capsule.ServiceProvider'))) {
            providers.push(macro @:pos(decl.pos) container.use(${decl}));
          } else {
            providers.push(macro @:pos(decl.pos) container.map(${decl}, ${tag}).toClass(${decl}).asShared());
          }
        }

        switch e.expr {
          case EArrayDecl(decls):
            for (decl in decls) switch decl {
              case macro @:tag(${tag}) ${def}: add(def, tag);
              default: add(decl, macro null); 
            }
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

      // todo: allow users to create their own 'new'
      public function new() {}
      
      public function __exportInto(child:capsule.Container) {
        var self = build();
        $b{exports};
      }

      public function build() {
        if (__c != null) return __c;
        var container = new capsule.Container();
        $b{providers};
        $b{imports};
        __c = container;
        return container;
      }

    }).fields);
  }

}

#end
