
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
      
      Frame pay_button = new Frame(){
        public void draw(float x, float y, float w, float h) {
          super.draw(x,y,w,h);
          getPosition()[0] = mouseX;
          getPosition()[1] = mouseY;
        }
      };
      pay_button.getSize()[0] = 250;
      pay_button.getSize()[1] = 100;
      pay_button.getOffset()[2] = -.5;
      pay_button.getOffset()[3] = -.5;
      //pay_button.setTextAlign(CENTER,CENTER);
      //pay_button.setText("PAY UR BILL");
      //pay_button.setTextFont(createFont("comic sans ms",24));
      pay_button.setTexture(new Texture("art/icons/pay up.png"));
      frame.add(pay_button);
    }
    
  };
  
}
