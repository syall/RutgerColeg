
void loadGameplay() {
  
  gameplay = new Screen(){
    
    public Entity player;
    public Map map;
    
    public void init() {
      
      bgm.pause();
      bgm.close();
      bgm = minim.loadFile("sound/music/ontheDANK.mp3");
      bgm.play();
      
      map = new Map(sketchPath()+"/data/maps/beta.map");
      base.add(map);
      
      player = new Entity(""){
        public void draw(float x, float y, float w, float h) {
          super.draw(x,y,w,h);
          float walk_speed = 5;
          if(key_input['w'-32]) { if(onground) { vy-=30; playSFX("sound/fx/Boing-sound.mp3"); } }
          if(key_input['s'-32]) { vy+=walk_speed; }
          if(key_input['d'-32]) { if(onground) vx+=walk_speed; }
          if(key_input['a'-32]) { if(onground) vx-=walk_speed; }
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
      final Frame walking_frame = new Frame();
      walking_frame.getSize()[2] = 2;
      walking_frame.getSize()[3] = 2;
      player.add(walking_frame);
      Texture walking = new Texture("art/model/walkinganim/walking.anim");
      walking.looped = true;
      walking.speed = .25;
      Tasks.add(walking);
      walking_frame.setTexture(walking);
      /*
      ArrayList<Frame> character = (ArrayList<Frame>)global_resources.get("character");
      player.addAll(character);
      */
      map.addEntity(player);
      
      final Frame idcard = new Frame();
      idcard.getSize()[0] = 480;
      idcard.getSize()[1] = 300;
      idcard.getPosition()[0] = 10;
      idcard.getPosition()[1] = 10;
      idcard.setTexture(new Texture("art/icons/rutgerID.png"));
      map.add(idcard);
    }
    
  };
  
}
