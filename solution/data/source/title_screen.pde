
void loadTitleScreen() {
  
  title_screen = new Screen(){
    
    public void init() {
      
      if(bgm!=null) {
        bgm.pause();
        bgm.close();
      }
      bgm = minim.loadFile("sound/on the banks of the old raritan.mp3",4096);
      bgm.loop();
      
      final Frame bg = new Frame();
      bg.getSize()[2] = 1;
      bg.getSize()[3] = 1;
      bg.setTexture(new Texture("art/background/colave.png"));
      base.add(bg);
      
      final Frame overlay = new Frame();
      overlay.getSize()[2] = 1;
      overlay.getSize()[3] = 1;
      bg.add(overlay);
      
      final Frame setting_screen = new Frame();
      setting_screen.getSize()[0] = -50;
      setting_screen.getSize()[1] = -50;
      setting_screen.getSize()[2] = 1;
      setting_screen.getSize()[3] = 1;
      setting_screen.getPosition()[2] = 1.5;
      setting_screen.getPosition()[3] = .5;
      setting_screen.getOffset()[2] = -.5;
      setting_screen.getOffset()[3] = -.5;
      setting_screen.setTexture(new Texture("art/def.png"));
      final Frame slider = new Frame();
      slider.getSize()[0] = 100;
      slider.getSize()[1] = 10;
      slider.getPosition()[2] = .5;
      slider.getPosition()[3] = .5;
      slider.getOffset()[2] = -.5;
      slider.getOffset()[3] = -.5;
      slider.setTexture(new Texture("art/black.png"));
      setting_screen.add(slider);
      
      final Frame slider_button = new Frame(){
        public boolean trolld;
        public boolean selected;
        public void draw(float x, float y, float w, float h) {
          super.draw(x,y,w,h);
          if(trolld) {
            if(!selected) {
              if(mousePressing() && mouseHovering()) {
                selected = true;
              }
            }
            if(mouseReleasing()) {
              selected = false;
            }
            if(selected) {
              getPosition()[0] = mouseX-slider.absolute_x+15;
            }
          } else {
            if(mousePressing() && mouseHovering()) {
              getPosition()[0] = 90;
              trolld = true;
            }
          }
          bgm.setGain(getPosition()[0]*100);
        }
      };
      slider_button.setMouseSensitive(true);
      slider_button.getSize()[0] = 10;
      slider_button.getSize()[1] = 10;
      slider_button.setTexture(new Texture("art/white.png"));
      slider.add(slider_button);
      
      {
        final Frame back = new Frame(){
          public void draw(float x, float y, float w, float h) {
            super.draw(x,y,w,h);
            if(mouseHovering() && mousePressing()) {
              
              Tasks.add(new FloatMover(-1,0,.05){
                public void apply() {
                  overlay.getPosition()[2] = get();
                }
              });
              
            }
          }
        };
        back.setMouseSensitive(true);
        back.getSize()[0] = 100;
        back.getSize()[1] = 40;
        back.getPosition()[0] = -10;
        back.getPosition()[1] = -10;
        back.getPosition()[2] = 1;
        back.getPosition()[3] = 1;
        back.getOffset()[2] = -1;
        back.getOffset()[3] = -1;
        back.setTexture(new Texture("art/def.png"));
        setting_screen.add(back);
      }
      overlay.add(setting_screen);
      
      final Frame deeprut = new Frame();
      deeprut.getSize()[0] = 500;
      deeprut.getSize()[1] = 200;
      deeprut.getPosition()[1] = 100;
      deeprut.getPosition()[2] = .5;
      deeprut.getOffset()[2] = -.5;
      deeprut.setTexture(new Texture("art/icons/deeprut.png"));
      overlay.add(deeprut);
      
      final Frame button_base = new Frame();
      button_base.getSize()[0] = 400;
      button_base.getSize()[1] = 200;
      button_base.getPosition()[2] = .5;
      button_base.getPosition()[3] = .5;
      button_base.getOffset()[2] = -.5;
      button_base.setTexture(new Texture("art/def.png"));
      {
        PFont font = createFont("comic sans ms",24);
        final String[] labels = new String[]{
            "START",
            "CONTINUE?",
            "SETTINGS"};
        final Frame[] buttons = new Frame[3];
        for(int i=0;i<buttons.length;i++) {
          final int index = i;
          buttons[i] = new Frame(){
            public void draw(float x, float y, float w, float h) {
              super.draw(x,y,w,h);
              if(mouseHover()) {
                getSize()[0] = -5;
                if(mousePressing()) {
                  switch(index) {
                    case 0:
                      println("play the game");
                      
                      Tasks.remove(title_screen);
                      Tasks.add(char_custom);
                      
                    break;
                    case 1:
                      println("continue?");
                    break;
                    case 2:
                      println("settings");
                      
                      Tasks.add(new FloatMover(0,-1,.1){
                        public void init() {
                          setType(LINEAR);
                        }
                        public void apply() {
                          overlay.getPosition()[2] = get();
                        }
                      });
                      
                    break;
                  }
                }
              } else {
                getSize()[0] = -10;
              }
            }
          };
          buttons[i].setMouseSensitive(true);
          buttons[i].getSize()[0] = -10;
          buttons[i].getSize()[1] = -10;
          buttons[i].setTextFont(font);
          buttons[i].setTextColor(color(0));
          buttons[i].setTextAlign(CENTER,CENTER);
          buttons[i].setText(labels[i]);
          buttons[i].getSize()[2] = 1;
          buttons[i].getSize()[3] = 1./buttons.length;
          buttons[i].getPosition()[2] = .5;
          buttons[i].getPosition()[1] = 10;
          buttons[i].getOffset()[2] = -.5;
          buttons[i].getOffset()[3] = i*1.09;
          buttons[i].setTexture(new Texture("art/def.png"));
          button_base.add(buttons[i]);
        }
      }
      overlay.add(button_base);
      
    }
  };
  
}
