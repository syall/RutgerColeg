
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
          if(key_input['w'-32]) { if(onground) { vy-=30; } }
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
      //player.setTexture(new Texture("art/background/dutta.jpg"));
      ArrayList<Frame> character = (ArrayList<Frame>)global_resources.get("character");
      player.addAll(character);
      map.addEntity(player);
    }
    
  };
  
}
