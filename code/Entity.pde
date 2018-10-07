
class Entity extends Frame {
  
  public float vx;
  public float vy;
  
  public float ax;
  public float ay;
  
  public float drag;
  public float friction;
  
  public boolean onground;
  
  public int state;
  
  public void setState(int value) {
    if(value!=state) {
      state = value;
      
    }
  }
  
  public Entity(String path) {
    super();
    getOffset()[3] = -1;
  }
  
  public void move() {
    getPosition()[0] += vx;
    getPosition()[1] += vy;
    vx += ax;
    vy += ay;
    vx *= (1-(onground?friction:drag));
    vy *= (1-drag);
  }
  
  public void collide(Map map) {
    
    onground = false;
    
    for(Map.Platform platform : map.platforms) {
      collide(platform);
    }
    
    if(pos[1]!=(pos[1]=min(pos[1],ground))) {
      vy = 0;
      onground = true;
    }
    if(pos[0]!=(pos[0]=max(pos[0],0))) {
      vx = 0;
    }
    
  }
  
  public void collide(Frame frame) {
    
    Ray.IntersectionInfo info = overlaps(frame);
    if(info!=null && info.element!=null) {
      if(frame instanceof Map.Platform) {
        
        Map.Platform bouncer = ((Map.Platform)frame);
        if(bouncer.type==4) {
          if(!bouncer.visible) {
            bouncer.visible = true;
            playSFX("sound/fx/roblox-death-sound_1.mp3");
            vx = -200;
            vy = -10;
            pos[1]--;
            onground = false;
          }
        }
        
        if(!((Map.Platform)frame).collides) {
          return;
        }
        
      }
      
      /*
      switch(info.element[0]) {
        case 0: vy=min(0,vy); pos[1]=frame.absolute_y-100; vy=0; onground=true; break;
        //case 1: vx=max(0,vx); pos[0]+=5; break;
        //case 2: vy=max(0,vy); pos[1]+=5; break;
        //case 3: vx=min(0,vx); pos[0]-=5; break;
      }
      */
    }
    
  }
  
}
