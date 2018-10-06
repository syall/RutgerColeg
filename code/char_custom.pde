
void loadCharacterCustomization() {
  
  char_custom = new Screen(){
    
    public Frame look_chooser;
    public Frame major_chooser;
    public Frame stat_chooser;
    
    public void init() {
      
      final Frame overlay = new Frame();
      overlay.getSize()[2] = 1;
      overlay.getSize()[3] = 1;
      base.add(overlay);
      
      final FloatMover overlay_x = new FloatMover(0,0,.2){
        public void init() {
          setType(EASE);
        }
        public void apply() {
          overlay.getPosition()[2] = get();
        }
      };
      Tasks.add(overlay_x);
      
      look_chooser = new Frame();
      major_chooser = new Frame();
      stat_chooser = new Frame();
      final Frame[] choosers = new Frame[]{look_chooser,major_chooser,stat_chooser};
      
      for(int i=0;i<choosers.length;i++) {
        final int next_index = (i+1)%choosers.length;
        Frame frame = choosers[i];
        frame.getSize()[0] = -30;
        frame.getSize()[1] = -30;
        frame.getSize()[2] = 1;
        frame.getSize()[3] = 1;
        frame.getPosition()[2] = .5+i;
        frame.getPosition()[3] = .5;
        frame.getOffset()[2] = -.5;
        frame.getOffset()[3] = -.5;
        frame.setTexture(new Texture("art/def.png"));
        {
          Frame next = new Frame(){
            public void draw(float x, float y, float w, float h) {
              super.draw(x,y,w,h);
              if(mouseHovering() && mousePressing()) {
                if(next_index>0) {
                  overlay.add(choosers[next_index]);
                  // overlay.getPosition()[2] += 1;
                  overlay_x.endAt(overlay_x.getEnd()-1);
                } else {
                  Tasks.remove(char_custom);
                  Tasks.add(gameplay);
                }
              }
            }
          };
          next.setMouseSensitive(true);
          next.getSize()[0] = 100;
          next.getSize()[1] = 40;
          next.getPosition()[0] = -10;
          next.getPosition()[1] = -10;
          next.getPosition()[2] = 1;
          next.getPosition()[3] = 1;
          next.getOffset()[2] = -1;
          next.getOffset()[3] = -1;
          next.setTexture(new Texture("art/def.png"));
          frame.add(next);
        }
      }
      
      overlay.add(choosers[0]);
    }
    
  };
  
}
