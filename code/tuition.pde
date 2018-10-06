
void loadTuition() {
  
  tuition = new Screen(){
    
    public void init() {
      Frame frame = new Frame(){
        public void draw(float x, float y, float w, float h) {
          super.draw(x,y,w,h);
          if(mousePressing() && mouseHover()) {
            Tasks.remove(tuition);
            Tasks.add(credits);
          }
        }
      };
      frame.setMouseSensitive(true);
      frame.getSize()[2] = 1;
      frame.getSize()[3] = 1;
      frame.setTexture(new Texture(sketchPath()+"/data/art/background/tution.png"));
      base.add(frame);
    }
    
  };
  
}
