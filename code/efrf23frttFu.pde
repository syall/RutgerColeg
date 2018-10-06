import ddf.minim.*;

public boolean pmousePressed;
public boolean[] key_input = new boolean[256];

public boolean mousePressing() {
  return mousePressed && !pmousePressed;
}

public boolean mouseReleasing() {
  return !mousePressed && pmousePressed;
}

public Screen title_screen;
public Screen char_custom;
public Screen gameplay;
public Screen credits;

public Minim minim;
public AudioPlayer bgm;

void setup() {
  
  size(640,480);
  noSmooth();
  
  minim = new Minim(this);
  
  surface.setTitle("survie the rutger coleg 1");
  surface.setIcon(createImage(1,1,ARGB));
  
  title_screen = new Screen(){
    public void init() {
      
      bgm = minim.loadFile("sound/on the banks of the old raritan loud.mp3",4096);
      bgm.play();
      
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
        back.getSize()[0] = 50;
        back.getSize()[1] = 20;
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
            "top text",
            "sample text",
            "bottom text"};
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
                      Tasks.add(gameplay);
                      
                    break;
                    case 1:
                      println("continue?");
                    break;
                    case 2:
                      println("settings");
                      
                      Tasks.add(new FloatMover(0,-1,.05){
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
  
  gameplay = new Screen(){
    
    public Entity player;
    public Map map;
    
    public void init() {
      
      bgm.pause();
      bgm.close();
      bgm = minim.loadFile("sound/music/2017-08-19.mp3");
      bgm.play();
      
      map = new Map(sketchPath()+"/data/maps/beta.map");
      
      player = new Entity(""){
        public void draw(float x, float y, float w, float h) {
          super.draw(x,y,w,h);
          float walk_speed = 2;
          if(key_input['w'-32]) { getPosition()[1]-=walk_speed; }
          if(key_input['s'-32]) { getPosition()[1]+=walk_speed; }
          if(key_input['d'-32]) { getPosition()[0]+=walk_speed; }
          if(key_input['a'-32]) { getPosition()[0]-=walk_speed; }
        }
      };
      player.getSize()[0] = 20;
      player.getSize()[1] = 20;
      player.setTexture(new Texture("art/def.png"));
      base.add(player);
    }
    
  };
  
  credits = new Screen(){
    public void init() {
      
    }
  };

  Tasks.add(title_screen);
}

void keyPressed() {
  key_input[keyCode] = true;
}

void keyReleased() {
  key_input[keyCode] = false;
}

void draw() {
  
  Tasks.handle();
  pmousePressed = mousePressed;
}
