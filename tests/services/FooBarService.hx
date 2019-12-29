package services;

class FooBarService {
  
  final fooService:FooService;

  public function new(fooService) {
    this.fooService = fooService;
  }

  public function getFooBar() {
    return fooService.getFoo() + ' bar';
  }

}
