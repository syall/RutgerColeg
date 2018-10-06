
class Entity extends Frame {
  
  public float vx;
  public float vy;
  
  public float ax;
  public float ay;
  
  public float drag;
  public float friction;
  
  public boolean onground;
  
  public Entity(String path) {
    super();
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
    
    if(pos[1]!=(pos[1]=min(pos[1],800))) {
      vy = 0;
      onground = true;
    }
    
  }
  
  public void collide(Frame frame) {
    
    Ray.IntersectionInfo info = overlaps(frame);
    if(info!=null && info.element!=null) {
      switch(info.element[0]) {
        case 0: vy=min(0,vy); pos[1]=frame.absolute_y-150; vy=0; onground=true; break;
        //case 1: vx=max(0,vx); pos[0]+=5; break;
        //case 2: vy=max(0,vy); pos[1]+=5; break;
        //case 3: vx=min(0,vx); pos[0]-=5; break;
      }
    }
    
  }
  
}
