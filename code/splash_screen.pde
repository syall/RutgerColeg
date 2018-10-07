
void loadSplashScreen() {
  
  splash_screen = new Screen() {
    
    public void init() {
      
      final float[] opacity = new float[1];
      final Frame overlay = new Frame() {
        public void draw(float x, float y, float w, float h) {
          fill(opacity[0]);
          rect(x,y,w,h);
          super.draw(x,y,w,h);
        }
      };
      overlay.getSize()[2] = 1;
      overlay.getSize()[3] = 1;
      overlay.setTextAlign(CENTER,CENTER);
      overlay.setTextFont(createFont("comic sans ms",72));
      overlay.setText("survie the rutger coleg 1");
      overlay.setTextColor(color(0));
      base.add(overlay);
      
      Tasks.add(new FloatMover(0,300,3){
        public void init() {
          setType(LINEAR);
        }
        public void apply() {
          opacity[0] = get();
        }
        public void onFinish() {
          Tasks.add(new FloatMover(255,-30,3){
            public void init() {
              setType(LINEAR);
            }
            public void apply() {
              opacity[0] = get();
            }
            public void onFinish() {
              Tasks.remove(splash_screen);
              Tasks.add(title_screen);
            }
          });
        }
      });
      
    }
    
  };
  
}
