package services;

class StringService {
  
  final data:String;

  public function new(data) {
    this.data = data;    
  }

  public function getString() {
    return data;
  }

}
