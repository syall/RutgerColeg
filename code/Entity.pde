
class Entity extends Frame {
  
  public float vx;
  public float vy;
  
  public float ax;
  public float ay;
  
  public Entity(String path) {
    super();
  }
  
  public void move() {
    pos[0] += vx += ax;
    pos[1] += vy += ay;
  }
  
  public void collide(Frame frame) {
    if(overlaps(frame)) {
      
    }
  }
  
}
