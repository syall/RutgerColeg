
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
  
  public boolean overlaps(Frame frame) {
    
    PMatrix2D matrix = absolute_coords.get();
    matrix.invert();
    
    float[] mouse = new float[]{mouseX,mouseY};
    matrix.mult(mouse,mouse);
    
    mouse_x = mouse[0];
    mouse_y = mouse[1];
    
    if(mouse_x>=0 && mouse_x<absolute_w &&
       mouse_y>=0 && mouse_y<absolute_h) {
      return true;
    }
    
    return false;   
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
    translate(-pivot_x,-pivot_y);
    
    draw(0,0,absolute_w,absolute_h);
    
    absolute_coords = (PMatrix2D)getMatrix().get();
    if(mouse_sensitive) {
      updateMouseStats();
    }
    
    for(Frame child : this) {
      child.handle(0,0,absolute_w,absolute_h);
    }
    
    popMatrix();
    
  }
  
}
