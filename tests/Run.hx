import architect.*;
import medic.Runner;

class Run {

  static function main() {
    var runner = new Runner();
    runner.add(new ModuleTest());
    runner.run();
  }

}
