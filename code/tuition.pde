
void loadTuition() {
  
  tuition = new Screen(){
    
    public void init() {
      Tasks.remove(tuition);
      Tasks.add(credits);
    }
    
  };
  
}
