
public class Frame extends ArrayList<Frame> {
  
  protected float[] pos = new float[4];
  protected float[] size = new float[4];
  protected float[] pivot = new float[4];
  protected float[] offset = new float[4];
  protected float[] angle = new float[1];
  
  protected boolean mouse_sensitive;
  protected boolean mouse_hover;
  protected float mouse_x;
  protected float mouse_y;
  
  protected boolean visible = true;
  
  protected String text;
  protected int text_align_x;
  protected int text_align_y;
  protected PFont font;
  protected color text_color;
  
  protected PMatrix2D absolute_coords;
  protected float absolute_x;
  protected float absolute_y;
  protected float absolute_w;
  protected float absolute_h;
  
  protected boolean flipped;
  
  protected Texture texture;
  
  public float[] getPosition() {
    return pos;
  }
  
  public float[] getSize() {
    return size;
  }
  
  public float[] getPivot() {
    return pivot;
  }
  
  public float[] getOffset() {
    return offset;
  }
  
  public float getAngle() {
    return angle[0];
  }
  
  public boolean mouseHovering() {
    return mouse_hover;
  }
  
  public void setAngle(float value) {
    angle[0] = value;
  }
  
  public void setText(String value) {
    text = value;
  }
  
  public void setTextAlign(int x, int y) {
    text_align_x = x;
    text_align_y = y;
  }
  
  public void setTextColor(color shade) {
    text_color = shade;
  }
  
  public void setTextFont(PFont font) {
    this.font = font;
  }
  
  public void draw(float x, float y, float w, float h) {
    if(visible) {
      if(texture!=null) {
        image(texture.get(),x,y,w,h);
      }
      if(text!=null) {
        textAlign(text_align_x,text_align_y);
        switch(text_align_x) {
          case CENTER: x += w/2; break;
          case RIGHT: x += w; break;
        }
        switch(text_align_y) {
          case CENTER: y += h/2; break;
          case BOTTOM: y += h; break;
        }
        fill(text_color);
        textFont(font);
        text(text,x,y);
      }
    }
  }
  
  public boolean getMouseSensitive() {
    return mouse_sensitive;
  }
  
  public void setMouseSensitive(boolean value) {
    mouse_sensitive = value;
  }
  
  public boolean mouseHover() {
    return mouse_hover;
  }
  
  public float mouseX() {
    return mouse_x;
  }
  
  public float mouseY() {
    return mouse_y;
  }
  
  public void updateMouseStats() {
    
    PMatrix2D matrix = absolute_coords.get();
    matrix.invert();
    
    float[] mouse = new float[]{mouseX,mouseY};
    matrix.mult(mouse,mouse);
    
    mouse_x = mouse[0];
    mouse_y = mouse[1];
    
    if(mouse_x>=0 && mouse_x<absolute_w &&
       mouse_y>=0 && mouse_y<absolute_h) {
      mouse_hover = true;
    } else {
      mouse_hover = false;
    }
    
  }
  
  public Ray.IntersectionInfo overlaps(Frame frame) {
    if(absolute_coords!=null) {
      
      float[][] vert0 = new float[][]{
          new float[]{0,0},
          new float[]{absolute_w,0},
          new float[]{absolute_w,absolute_h},
          new float[]{0,absolute_h}};
      for(int i=0;i<vert0.length;i++) {
        absolute_coords.mult(vert0[i],vert0[i]);
      }
      
      float[][] vert1 = new float[][]{
          new float[]{0,0},
          new float[]{frame.absolute_w,0},
          new float[]{frame.absolute_w,frame.absolute_h},
          new float[]{0,frame.absolute_h}};
      for(int i=0;i<vert1.length;i++) {
        frame.absolute_coords.mult(vert1[i],vert1[i]);
      }
      
      Ray.IntersectionInfo info = null;
      
      Ray ray = new Ray();
      for(int i=0;i<vert0.length;i++) {
        
        float[] va0 = vert0[i];
        float[] vb0 = vert0[(i+1)%vert0.length];
        
        ray.x = va0[0];
        ray.y = va0[1];
        ray.dx = vb0[0]-ray.x;
        ray.dy = vb0[1]-ray.y;
        
        for(int j=0;j<vert1.length;j++) {
          float[] va1 = vert1[j];
          float[] vb1 = vert1[(j+1)%vert1.length];
          
          Ray.IntersectionInfo hit = ray.findIntersection(va1,vb1);
          if(hit!=null && hit.t0>=0 && hit.t0<=1) {
            if(info==null || (min(info.t1,1-info.t1)>min(hit.t1,1-hit.t1))) {
              info = hit;
              info.element = new int[]{j};
            }
          }
          
        }
        
      }
      
      return info;
    }
    return null;
  }
  
  public void setTexture(Texture value) {
    texture = value;
  }
  
  public void handle(float x, float y, float w, float h) {
    
    absolute_x = x+pos[0]+pos[2]*w;
    absolute_y = y+pos[1]+pos[3]*h;
    absolute_w = size[0]+size[2]*w;
    absolute_h = size[1]+size[3]*h;
    
    float pivot_x = pivot[0]+pivot[2]*absolute_w;
    float pivot_y = pivot[1]+pivot[3]*absolute_h;
    float offset_x = offset[0]+offset[2]*absolute_w;
    float offset_y = offset[1]+offset[3]*absolute_h;
    
    pushMatrix();
    
    translate(
        pivot_x+offset_x+absolute_x,
        pivot_y+offset_y+absolute_y);
    rotate(angle[0]);
    if(flipped) {
      scale(-1,1);
    }
    translate(-pivot_x,-pivot_y);
    
    draw(0,0,absolute_w,absolute_h);
    
    absolute_coords = ((PMatrix2D)getMatrix()).get();
    
    if(mouse_sensitive) {
      updateMouseStats();
    }
    
    if(visible) {
      for(int i=0;i<size();i++) {
        get(i).handle(0,0,absolute_w,absolute_h);
      }
    }
    
    popMatrix();
    
  }
  
}
