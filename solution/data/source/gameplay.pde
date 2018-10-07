
void loadGameplay() {
  
  gameplay = new Screen(){
    
    public Entity player;
    public Map map;
    
    public void init() {
      
      bgm.pause();
      bgm.close();
      bgm = minim.loadFile("sound/music/ontheDANK (1).mp3");
      bgm.loop();
      
      map = new Map(sketchPath()+"/data/maps/beta.map");
      base.add(map);
      
      final Frame walking_frame = new Frame();
      final Frame idle = new Frame();
      player = new Entity(""){
        public void draw(float x, float y, float w, float h) {
          super.draw(x,y,w,h);
          float walk_speed = 5;
          boolean walking = false;
          if(key_input['w'-32]) { walking=true; if(onground) { vy-=30; playSFX("sound/fx/Boing-sound.mp3"); } }
          if(key_input['s'-32]) { walking=true; vy+=walk_speed; }
          if(key_input['d'-32]) { walking=true; if(onground) vx+=walk_speed; }
          if(key_input['a'-32]) { walking=true; if(onground) vx-=walk_speed; player.flipped=true; } else {
            player.flipped = false; }
          if(walking) {
            walking_frame.visible = true;
            idle.visible = false;
          } else {
            walking_frame.visible = false;
            idle.visible = true;
          }
          move();
          collide(map);
          if(pos[0]>5000) {
            Tasks.remove(gameplay);
            Tasks.add(tuition);
          }
        }
      };
      player.drag = .01;
      player.friction = .5;
      player.ay = 1;
      player.getSize()[0] = 200;
      player.getSize()[1] = 280;
      walking_frame.getSize()[2] = 2;
      walking_frame.getSize()[3] = 2;
      walking_frame.getPosition()[0] = -80;
      walking_frame.getPosition()[1] = -70;
      player.add(walking_frame);
      Texture walking = new Texture("art/model/pig/walking.anim");
      walking.looped = true;
      walking.speed = .25;
      Tasks.add(walking);
      walking_frame.setTexture(walking);
      idle.getSize()[2] = 1;
      idle.getSize()[3] = 1;
      player.add(idle);
      ArrayList<Frame> character = (ArrayList<Frame>)global_resources.get("character");
      idle.addAll(character);
      map.addEntity(player);
      
      final Frame idcard = new Frame();
      idcard.getSize()[0] = 240;
      idcard.getSize()[1] = 150;
      idcard.getPosition()[0] = 10;
      idcard.getPosition()[1] = 10;
      idcard.setTexture(new Texture("art/icons/rutgerID.png"));
      final Frame person = new Frame();
      person.getPosition()[0] = 10;
      person.getPosition()[1] = 50;
      person.getSize()[0] = 75;
      person.getSize()[1] = 90;
      person.addAll(character);
      idcard.add(person);
      final Frame name = new Frame();
      name.getPosition()[0] = 80;
      name.getPosition()[1] = 55;
      name.setTextAlign(LEFT,TOP);
      name.setTextFont(createFont("courier new bold",12));
      name.setTextColor(color(0));
      Object nemr = global_resources.get("name");
      if(nemr!=null) {
        name.setText((String)nemr);
      }
      idcard.add(name);
      map.add(idcard);
    }
    
  };
  
}
