import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import ddf.minim.*; 
import java.io.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class efrf23frttFu extends PApplet {



public boolean pmousePressed;
public boolean[] key_input = new boolean[256];

public float ground = 1020;

public boolean mousePressing() {
  return mousePressed && !pmousePressed;
}

public boolean mouseReleasing() {
  return !mousePressed && pmousePressed;
}

public HashMap<String,Object> global_resources = new HashMap<String,Object>();

public Screen splash_screen;
public Screen title_screen;
public Screen char_custom;
public Screen gameplay;
public Screen tuition;
public Screen credits;

public Minim minim;
public AudioPlayer bgm;
public ArrayList<AudioPlayer> sfx = new ArrayList<AudioPlayer>();

public int scroll;

public void playSFX(String path) {
  AudioPlayer sound = minim.loadFile(path,4096);
  sound.play();
  sfx.add(sound);
}

public void setup() {
  
  
  
  
  minim = new Minim(this);
  
  surface.setTitle("survie the rutger coleg 1");
  surface.setIcon(createImage(1,1,ARGB));
  
  loadSplashScreen();
  loadTitleScreen();
  loadCharacterCustomization();
  loadGameplay();
  loadTuition();
  loadCredits();

  Tasks.add(splash_screen);
  //Tasks.add(title_screen);
}

public void keyPressed() {
  key_input[keyCode] = true;
}

public void keyReleased() {
  key_input[keyCode] = false;
}

public void mouseWheel(MouseEvent e) {
  scroll = e.getCount();
}

public void draw() {
  
  Tasks.handle();
  pmousePressed = mousePressed;
  
  for(int i=sfx.size()-1;i>=0;i--) {
    if(!sfx.get(i).isPlaying()) {
      sfx.remove(i);
    }
  }
  
  scroll = 0;
}

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
            playSFX("sound/fx/bass.mp3");
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


static class FileIO {
  
  public static String read(String path) {
    try {
      BufferedReader in = new BufferedReader(
          new InputStreamReader(
          new FileInputStream(path),"UTF8"));
      StringBuilder text = new StringBuilder();
      String line = null;
      while((line=in.readLine())!=null) {
        text.append(line);
        text.append("\n");
      }
      in.close();
      return text.toString();
    } catch(IOException e) {}
    return null;
  }
  
  public static String getExtension(String path) {
    return path.substring(path.lastIndexOf(".")+1).toLowerCase().trim();
  }
  
  public static String getDirectory(String path) {
    return path.substring(0,path.lastIndexOf("/")+1);
  }
  
}

public abstract class FloatMover implements Runnable {
  
  public float start;
  public float end;
  public float rate;
  public float time;
  public float value;
  public float threshold;
  
  public int type;
  public static final int LINEAR = 0;
  public static final int EASE = 1;
  public static final int SINE = 2;
  public static final int SHAKE = 3;
  
  public FloatMover(float start, float end, float rate) {
    set(start);
    startAt(start);
    endAt(end);
    setRate(rate);
    init();
  }
  
  public FloatMover(float start, float end) {
    this(start,end,1);
  }
  
  public FloatMover(float value) {
    this(value,value);
  }
  
  public void init() {}
  
  public void startAt(float start) { this.start=start; }
  public void endAt(float end) { this.end=end; Tasks.add(this); }
  public void setRate(float rate) { this.rate=rate; }
  public void setTime(float time) { this.time=time; }
  public void set(float value) { this.value=value; Tasks.add(this); }
  public void setThreshold(float threshold) { this.threshold=threshold; }
  public void setType(int value) { this.type = value; }
  
  public float getStart() { return start; }
  public float getEnd() { return end; }
  public float getRate() { return rate; }
  public float getTime() { return time; }
  public float get() { return value; }
  public float getThreshold() { return threshold; }
  public int getType() { return type; }
  
  public abstract void apply();
  
  public void onFinish() {}
  
  public void run() {
    
    time += rate;
    
    boolean finished = false;
    
    switch(type) {
      case LINEAR:
        finished = ((value>end)!=((value+=rate*(value>end?-1:1))>end));
      break;
      case EASE:
        value += (end-value)*rate;
      break;
      case SINE:
        value = start+(end-start)*(sin(time)*.5f+.5f);
      break;
      case SHAKE:
        value = time%1;
        if(floor(value)%2==1) {
          value = 1-value;
        }
        value = start+(end-start)*value;
      break;
    }
    
    if(abs(value-end)<threshold) {
      finished = true;
    }
    
    if(finished) {
      onFinish();
      value = end;
      Tasks.remove(this);
    }
    
    apply();
  }
  
}

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
  protected int text_color;
  
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
  
  public void setTextColor(int shade) {
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

class InfoTree {
  
  class Node extends ArrayList<Node> {
    
    private Node parent;
    private String name;
    private String[] text;
    
    public void setParent(Node node) {
      node.add(this);
      parent = node;
    }
    
    public Node getParent() {
      return parent;
    }
    
    public void setName(String value) {
      name = value;
    }
    
    public String getName() {
      return name;
    }
    
    public void setText(String[] value) {
      text = value;
    }
    
    public String[] getText() {
      return text;
    }
    
    public Node getChild(String name) {
      for(Node node : this) {
        if(name.equals(node.getName())) {
          return node;
        }
      }
      return null;
    }
    
    public String toString() {
      StringBuilder str = new StringBuilder();
      if(getName()!=null) {
        str.append(getName());
      }
      str.append(" : ");
      if(size()>0) {
        str.append(" {\n");
        for(Node node : this) {
        for(String line : node.toString().split("\n")) {
          str.append("\t"+line);
          str.append("\n");
        }
        }
        str.append("}");
      } else if(getText()!=null) {
        if(getName()!=null) {
          str.append(" ");
        }
        for(int i=0;i<getText().length;i++) {
          if(i>0) {
            str.append(" , ");
          }
          str.append(getText()[i]);
        }
      }
      str.append("\n");
      return str.toString();
    }
    
    public int indexOf(Node node) {
      for(int i=0;i<size();i++) {
        if(get(i)==node) {
          return i;
        }
      }
      return -1;
    }
    
    public ArrayList<Node> getDescendants() {
      ArrayList<Node> descendants = new ArrayList<Node>();
      descendants.addAll(this);
      for(int i=0;i<descendants.size();i++) {
        descendants.addAll(descendants.get(i));
      }
      return descendants;
    }
    
  }
  
  private Node root;
  
  public InfoTree(String path) {
    
    root = new Node();
    Node node = root;
    
    String text = FileIO.read(path);
    if(text!=null) {
      
      StringBuilder name = new StringBuilder();
      for(int i=0;i<text.length();i++) {
        char c = text.charAt(i);
        if(c=='{') {
          Node next = new Node();
          if(!name.toString().trim().isEmpty()) {
            next.setName(name.toString().trim());
            name.setLength(0);
          }
          next.setParent(node);
          node = next;
        } else if(c=='}') {
          if(!name.toString().trim().isEmpty()) {
            Node last = new Node();
            last.setName(name.toString().trim());
            name.setLength(0);
            last.setParent(node);
          }
          node = node.getParent();
        } else if(c=='\n') {
          if(!name.toString().trim().isEmpty()) {
            Node next = new Node();
            next.setName(name.toString().trim());
            name.setLength(0);
            next.setParent(node);
          }
        } else {
          name.append(c);
        }
      }
      
    }
    
    for(Node child : getDescendants()) {
      String name = child.getName();
      if(name!=null) {
        if(name.indexOf(" ")!=-1 || name.indexOf(",")!=-1) {
          int space = name.indexOf(" ");
          String real_name = null;
          String properties = null;
          if(space!=-1) {
            real_name = name.substring(0,space);
            properties = name.substring(space+1);
          } else {
            properties = name;
          }
          child.setName(real_name);
          String[] data = properties.split(",");
          for(int i=0;i<data.length;i++) {
            data[i] = data[i].trim();
          }
          child.setText(data);
        }
      }
    }
    
  }
  
  public Node get(String path) {
    Node node = root;
    String[] path_split = path.split("\\.");
    for(int i=0;i<path_split.length;i++) {
      node = node.getChild(path_split[i]);
      if(node==null) {
        return null;
      }
    }
    return node;
  }
  
  public String toString() {
    StringBuilder str = new StringBuilder();
    for(Node node : root) {
      str.append(node.toString());
    }
    return str.toString();
  }
  
  public ArrayList<Node> getDescendants() {
    return root.getDescendants();
  }
  
}

public class Map extends Frame {
  
  public class Platform extends Frame {
    
    private int type;
    public static final int SOLID = 0;
    public static final int LEDGE = 1;
    public static final int AIR = 2;
    public static final int FALLING = 3;
    public static final int SWIMMABLE = 4;
    
    public boolean collides;
    
    public Platform(InfoTree tree, InfoTree.Node node) {
      
      for(InfoTree.Node child : node) {
        if(child.getName()!=null) {
          switch(child.getName()) {
            case "position":
              for(int i=0;i<4;i++) {
                getPosition()[i] = parseFloat(child.getText()[i]);
              }
            break;
            case "size":
              for(int i=0;i<4;i++) {
                getSize()[i] = parseFloat(child.getText()[i]);
              }
            break;
            case "pivot":
              for(int i=0;i<4;i++) {
                getPivot()[i] = parseFloat(child.getText()[i]);
              }
            break;
            case "offset":
              for(int i=0;i<4;i++) {
                getOffset()[i] = parseFloat(child.getText()[i]);
              }
            break;
            case "texture":
              setTexture(new Texture(sketchPath()+"/data/"+tree.get("texture."+child.getText()[0]).getText()[0]));
            break;
            case "collision":
              collides = parseInt(child.getText()[0])!=0;
            break;
            case "type":
              type = parseInt(child.getText()[0]);
              if(type==4) {
                visible = false;
              }
            break;
          }
        }
        if(child.size()>0) {
          Platform platform = new Platform(tree,child);
          add(platform);
          platforms.add(platform);
        }
      }
      
    }
    
  }
  
  private ArrayList<Platform> platforms = new ArrayList<Platform>();
  private ArrayList<Entity> entities = new ArrayList<Entity>();
  private ArrayList<Frame> backgrounds = new ArrayList<Frame>();
  public Frame overlay;
  
  public Map(String path) {
    
    InfoTree info = new InfoTree(path);
    
    for(InfoTree.Node node : info.get("background")) {
      Frame bg = new Frame();
      bg.setTexture(new Texture(sketchPath()+"/data/"+info.get("texture."+node.getText()[1]).getText()[0]));
      bg.getSize()[0] = bg.texture.get().width;
      bg.getSize()[1] = bg.texture.get().height;
      add(bg);
      backgrounds.add(bg);
    }
    
    overlay = new Frame();
    overlay.getSize()[2] = 1;
    overlay.getSize()[3] = 1;
    /*
    Tasks.add(new FloatMover(0,0,.1){
      public void init() {
        setType(LINEAR);
      }
      public void apply() {
        endAt(-entities.get(0).getPosition()[0]+width/2);
        overlay.getPosition()[0] = get();
      }
    });
    Tasks.add(new FloatMover(0,0,.1){
      public void init() {
        setType(LINEAR);
      }
      public void apply() {
        endAt(-entities.get(0).getPosition()[1]+height/2);
        overlay.getPosition()[1] = get();
      }
    });
    */
    Tasks.add(new Runnable(){public void run(){
      overlay.getPosition()[0] += (min(0,-entities.get(0).getPosition()[0]+width/2)-overlay.getPosition()[0])*.2f;
      overlay.getPosition()[1] += (min(0,-entities.get(0).getPosition()[1]+height/2+200)-overlay.getPosition()[1])*.2f;
      for(Frame frame : backgrounds) {
        frame.getPosition()[0] = overlay.getPosition()[0]*1;
        frame.getPosition()[1] = overlay.getPosition()[1]*1+150;
      }       
    }});
    add(overlay);
    
    for(InfoTree.Node node : info.get("platform")) {
      if(node.size()>0) {
        Platform platform = new Platform(info,node);
        platforms.add(platform);
        overlay.add(platform);
      }
    }
    
    getSize()[2] = 1;
    getSize()[3] = 1;
  }
  
  public void addEntity(Entity frame) {
    overlay.add(frame);
    entities.add(frame);
  }
  
}

class Ray {
  
  public class IntersectionInfo {
    
    private float t0; // the ray
    private float t1; // the surface
    private float[] position;
    private int[] element;
    
    public IntersectionInfo(float t0, float t1, float[] position) {
      this.t0 = t0;
      this.t1 = t1;
      this.position = position;
    }
    
  }
  
  public float x;
  public float y;
  public float dx;
  public float dy;
  
  public IntersectionInfo findIntersection(float[] v0, float[] v1) {
    
    float a = v0[0];
    float b = v0[1];
    float da = v1[0]-a;
    float db = v1[1]-b;
    
    float det = da*dy-db*dx;
    if(det!=0) {
      float t0 = (db*(x-a)-da*(y-b))/det;
      float t1 = (dy*(x-a)-dx*(y-b))/det;
      if(t0>=0 && t1>=0 && t1<=1) {
        return new IntersectionInfo(t0,t1,new float[]{
            ((x+dx*t0)+(a+da*t1))/2,
            ((y+dy*t0)+(b+db*t1))/2});
      }
    }
    
    return null;
  }
  
}

abstract class Screen extends Frame implements Runnable {
  
  protected Frame base;
  
  public Screen() {
    base = new Frame();
    base.getSize()[2] = 1;
    base.getSize()[3] = 1;
  }
  
  public abstract void init();
  
  public void run() {
    base.handle(0,0,width,height);
  }
  
}

public static class Tasks {
  
  public static class FloatMover implements Runnable {
    
    private float[] value;
    private int index;
    
    private float xi;   // starting value
    private float xf;   // target value
    private float rate; // speed
    private float hold; // threshold
    private float time; // used only when time-varying
    
    private int type;
    private boolean time_inv; // time invariant?
    
    public static final int LINEAR = 0;
    public static final int SMOOTH = 1;
    public static final int SINE = 2;
    public static final int TRIANGLE = 3;
    
    public FloatMover(float[] value, int index) {
      this.value = value;
      this.index = index;
    }
    
    public FloatMover(float[] value) {
      this(value,0);
    }
    
    public FloatMover preset(float xi, float xf, float rate, float hold, int type, boolean time_inv) {
      value[index] = xi;
      this.xi = xi;
      this.xf = xf;
      this.rate = rate;
      this.hold = hold;
      this.type = type;
      this.time_inv = time_inv;
      return this;
    }
    
    public float get() { return value[index]; }
    public void set(float value) { this.value[index]=value; }
    public float getStart() { return xi; }
    public void setStart(float value) { xi = value; }
    public float getEnd() { return xf; }
    public void setEnd(float value) { xf = value; }
    public float getRate() { return rate; }
    public void setRate(float value) { rate = value; }
    public float getThreshold() { return hold; }
    public void setThreshold(float value) { hold = value; }
    public int getType() { return type; }
    public void setType(int value) { type = value; }
    public boolean getTimeInvariant() { return time_inv; }
    public void setTimeInvariant(boolean value) { time_inv = value; }
    
    public void run() {
      
      if(getTimeInvariant()) {
        switch(type) {
          case LINEAR:
            if(value[index]!=xf) {
              if((value[index]>=xf)!=((value[index]+=(xf>value[index]?1:-1)*rate)>=xf)) {
                value[index] = xf;
              }
            }
          break;
          case SMOOTH:
            if(value[index]!=xf) {
              value[index] += (xf-value[index])*rate;
              if(abs(value[index]-xf)<hold) {
                value[index] = xf;
              }
            }
          break;
          case SINE:
          {
            float xi = min(this.xi,this.xf);
            float xf = max(this.xi,this.xf);
            value[index] = min(max(value[index],xi),xf);
            float angle = asin((value[index]-xi)/(xf-xi)*2-1);
            angle += rate;
            if(angle>=HALF_PI || angle<=-HALF_PI) {
              rate *= -rate;
            }
            value[index] = xi+(sin(angle)*.5f+.5f)*(xf-xi);
          }
          break;
          case TRIANGLE:
          {
            float xi = min(this.xi,this.xf);
            float xf = max(this.xi,this.xf);
            value[index] = min(max(value[index],xi),xf);
            value[index] += rate;
            if(value[index]<=xi || value[index]>=xf) {
              rate = -rate;
            }
          }
          break;
        }
      } else { 
        switch(type) {
          case LINEAR:
            if(value[index]!=xf) {
              time += rate;
              if(time>=1) {
                value[index] = xf;
              } else {
                value[index] = xi+(xf-xi)*time;
              }
            }
          break;
          case SMOOTH:
            if(value[index]!=xf) {
              time += rate;
              if(time>=1) {
                value[index] = xf;
              } else {
                value[index] = (-2*time+3)*time*time;
              }
            }
          break;
          case SINE:
            time += rate;
            value[index] = xi+(xf-xi)*(sin(time)*.5f+.5f);
          break;
          case TRIANGLE:
            time += rate;
            
          break;
        }
      }
    }
    
  }
  /*
  private static final HashMap<String,ArrayList<Runnable>> tasks = new HashMap<String,ArrayList<Runnable>>();
  
  public static void handle() {
    for(String key : tasks.keySet()) {
      ArrayList<Runnable> tl = tasks.get(key);
      for(int i=tl.size()-1;i>=0;i--) {
        tl.get(i).run();
      }
    }
  }
  
  public static void add(String key, Runnable task) {
    ArrayList<Runnable> tl = tasks.get(key);
    if(tl==null) {
      tl = new ArrayList<Runnable>();
      tasks.put(key,tl);
    }
    tl.add(task);
  }
  
  public static void add(Runnable task) {
    add("~",task);
    if(task instanceof Screen) {
      ((Screen)task).init();
    }
  }
  
  public static void remove(Runnable task) {
    for(String key : tasks.keySet()) {
      ArrayList<Runnable> tl = tasks.get(key);
      if(tl.remove(task)) {
        break;
      }
    }
  }
  
  public static void clear(String key) {
    ArrayList<Runnable> tl = tasks.get(key);
    if(tl!=null) {
      tl.clear();
    }
  }
  
  public static void clear() {
    tasks.clear();
  }
  */
  private static final ArrayList<Runnable> tasks = new ArrayList<Runnable>();
  
  public static void handle() {
    for(int i=tasks.size()-1;i>=0;i--) {
    if(tasks.size()>i) {
      tasks.get(i).run();
    }
    }
  }
  
  public static void add(Runnable task) {
    if(!tasks.contains(task)) {
      if(task instanceof Screen) {
        ((Screen)task).base.clear();
        ((Screen)task).init();
      }
      tasks.add(task);
    }
  }
  
  public static void remove(Runnable task) {
    tasks.remove(task);
  }
  
  public static void clear() {
    tasks.clear();
  }
  
}

class Texture implements Runnable {

  private PImage[] frames;
  private float[] delays;

  private int index;

  private float overtime;
  private float speed;
  
  private boolean looped;
  private boolean finished;
  
  private Texture next = this;
  
  public Texture(String path) {
    
    String ext = FileIO.getExtension(path);

    switch(ext) {
    case "png": 
    case "jpg":
      frames = new PImage[]{loadImage(path)};
      delays = new float[]{1};
      break;
    case "anim":
      String dir = FileIO.getDirectory(path);
      String[] lines = FileIO.read(sketchPath()+"/data/"+path).trim().split("\n");
      frames = new PImage[lines.length];
      delays = new float[lines.length];
      float delay = 1;
      for (int i=0; i<lines.length; i++) {
        String[] info = lines[i].trim().split(" ");
        frames[i] = loadImage(dir+info[0]);
        if (info.length>1) {
          delay = parseFloat(info[1]);
        }
        delays[i] = delay;
      }
      speed = 1;
      break;
    }
  }

  public void update() {
    if(!finished) {
      overtime += speed;
      while(overtime>=delays[index]) {
        overtime -= delays[index];
        index++;
        if(index>=frames.length) {
          if(looped) {
            index = 0;
          } else {
            index--;
            finished = true;
          }
        }
      }
    }
  }

  public PImage get() {
    return frames[index];
  }
  
  public Texture getNext() {
    return next;
  }
  
  public void run() {
    update();
  }
  
}

public void loadCharacterCustomization() {
  
  char_custom = new Screen(){
    
    public Frame name_chooser;
    public Frame look_chooser;
    public Frame major_chooser;
    public Frame stat_chooser;
    
    public AudioPlayer bgm0 = null;
    
    public void init() {
      
      if(bgm!=null) {
        bgm.pause();
        bgm.close();
      }
      bgm0 = minim.loadFile("sound/music/rutgersFight loud.mp3");
      bgm = minim.loadFile("sound/music/rutgersFight (1).mp3");
      bgm0.loop();
      bgm0.setGain(-1000000);
      bgm.loop();
      
      base.setTexture(new Texture("art/background/hc.jpg"));
      final Frame overlay = new Frame();
      overlay.getSize()[2] = 1;
      overlay.getSize()[3] = 1;
      base.add(overlay);
      
      final FloatMover overlay_x = new FloatMover(0,0,.2f){
        public void init() {
          setType(EASE);
        }
        public void apply() {
          overlay.getPosition()[2] = get();
        }
      };
      Tasks.add(overlay_x);
      
      name_chooser = new Frame();
      look_chooser = new Frame();
      major_chooser = new Frame();
      stat_chooser = new Frame();
      final Frame[] choosers = new Frame[]{name_chooser,look_chooser,major_chooser,stat_chooser};
      
      for(int i=0;i<choosers.length;i++) {
        final int next_index = (i+1)%choosers.length;
        Frame frame = choosers[i];
        frame.getSize()[0] = -70;
        frame.getSize()[1] = -70;
        frame.getSize()[2] = 1;
        frame.getSize()[3] = 1;
        frame.getPosition()[2] = .5f+i;
        frame.getPosition()[3] = .5f;
        frame.getOffset()[2] = -.5f;
        frame.getOffset()[3] = -.5f;
        frame.setTexture(new Texture("art/background/hc.jpg"));
        {
          Frame next = new Frame(){
            public void draw(float x, float y, float w, float h) {
              super.draw(x,y,w,h);
              if(mouseHovering() && mousePressing()) {
                if(next_index>0) {
                  overlay.add(choosers[next_index]);
                  // overlay.getPosition()[2] += 1;
                  overlay_x.endAt(overlay_x.getEnd()-1);
                } else {
                  Tasks.remove(char_custom);
                  Tasks.add(gameplay);
                }
              }
            }
          };
          next.setMouseSensitive(true);
          next.getSize()[0] = 100;
          next.getSize()[1] = 40;
          next.getPosition()[0] = -10;
          next.getPosition()[1] = -10;
          next.getPosition()[2] = 1;
          next.getPosition()[3] = 1;
          next.getOffset()[2] = -1;
          next.getOffset()[3] = -1;
          next.setTexture(new Texture("art/def.png"));
          next.setTextColor(color(0));
          next.setTextFont(createFont("cambria",24));
          next.setTextAlign(CENTER,CENTER);
          next.setText("-->");
          frame.add(next);
        }
      }
      
      final Frame stats = new Frame();
      stats.getSize()[0] = 351;
      stats.getSize()[1] = 424;
      stats.getPosition()[3] = .5f;
      stats.getOffset()[3] = -.5f;
      stats.getPosition()[2] = .5f;
      stats.getOffset()[2] = -.5f;
      stats.setTexture(new Texture("art/background/stats.png"));
      stat_chooser.add(stats);
      
      final Frame look_frame = new Frame();
      look_frame.getSize()[0] = 476;
      look_frame.getSize()[1] = 670;
      look_frame.getPosition()[3] = .5f;
      look_frame.getPosition()[0] = 70;
      look_frame.getOffset()[3] = -.5f;
      look_frame.setTexture(new Texture("art/def.png"));
      
      String[] parts = new String[]{
          "art/model/skin.anim",
          "art/model/shoes.anim",
          "art/model/pants.anim",
          "art/model/shirts.anim",
          "art/model/hair.anim"};
      final String[] identify = new String[]{
          "body",
          "footwear",
          "pant",
          "shirt",
          "hair"};
      //PGraphics canvas = createGraphics(476,670,JAVA2D);
      
      ArrayList<Frame> character = new ArrayList<Frame>();
      global_resources.put("character",character);
      for(int i=0;i<parts.length;i++) {
        /*
        for(int j=0;j<255;j+=10) {
          final Frame part = new Frame();
          part.getSize()[2] = 1;
          part.getSize()[3] = 1;
          part.setTexture(new Texture(parts[i]));
          canvas.beginDraw();
          canvas.clear();
          canvas.colorMode(HSB);
          canvas.tint(j,255,255);
          canvas.image(part.texture.frames[0],0,0,canvas.width,canvas.height);
          canvas.endDraw();
          part.texture.frames[0] = canvas.get();
          look_frame.add(part);
        }
        */
        final Frame part = new Frame();
        part.getSize()[2] = 1;
        part.getSize()[3] = 1;
        final Texture part_texture = new Texture(parts[i]);
        part_texture.looped = true;
        part.setTexture(part_texture);
        look_frame.add(part);
        character.add(part);
        
        final Frame switcher = new Frame(){
          public void draw(float x, float y, float w, float h) {
            super.draw(x,y,w,h);
            if(mousePressing() && mouseHovering()) {
              part_texture.update();
            }
          }
        };
        switcher.setMouseSensitive(true);
        switcher.getSize()[0] = 70;
        switcher.getSize()[1] = 40;
        switcher.getPosition()[0] = 100;
        switcher.getPosition()[1] = -100*i-100;
        switcher.getPosition()[2] = 1;
        switcher.getPosition()[3] = 1;
        switcher.setTextAlign(LEFT,CENTER);
        switcher.setTextColor(color(0));
        switcher.setTextFont(createFont("comic sans ms",16));
        switcher.setText(identify[i]);
        switcher.setTexture(new Texture("art/def.png"));
        look_frame.add(switcher);
      }
      
      look_chooser.add(look_frame);
      
      final String[] lines = FileIO.read(sketchPath()+"/data/majors.txt").split("\n");
      final int line_count = 15;
      final int[] line_scroll = new int[1];
      final Frame[] major_list = new Frame[1];
      final Frame major_list_dropdown = new Frame(){
        public void draw(float x, float y, float w, float h) {
          super.draw(x,y,w,h);
          if(mouseHovering()) {
            line_scroll[0] += scroll;
            if(mousePressing()) {
              int index = (int)((mouseY-absolute_y-100)/20)+line_scroll[0];
              if(index>=0 && index<lines.length) {
                major_list[0].setText(lines[index]);
              } else {
                major_list[0].setText("ur mum lmao");
              }
            }
          }
          if(visible) {
            line_scroll[0] = max(0,min(line_scroll[0],lines.length-line_count));
            for(int i=line_scroll[0];i<line_count+line_scroll[0];i++) {
              textAlign(LEFT,CENTER);
              fill(0);
              text(lines[i],x,y+20*(i-line_scroll[0])+10);
            }
          }
        }
      };
      major_list_dropdown.setMouseSensitive(true);
      major_list_dropdown.getSize()[2] = 1;
      major_list_dropdown.getSize()[3] = 15;
      major_list_dropdown.getPosition()[3] = 1;
      major_list_dropdown.setTexture(new Texture("art/white.png"));
      major_list[0] = new Frame(){
        
        public void draw(float x, float y, float w, float h) {
          super.draw(x,y,w,h);
          if(mousePressing() && mouseHovering()) {
            major_list_dropdown.visible = !major_list_dropdown.visible;
          }
        }
        
      };
      major_list[0].setTexture(new Texture("art/white.png"));
      major_list_dropdown.visible = false;
      major_list[0].setTextColor(color(0));
      major_list[0].setTextAlign(LEFT,CENTER);
      major_list[0].setTextFont(createFont("courier new bold",12));
      major_list[0].setText(lines[0]);
      major_list[0].add(major_list_dropdown);
      major_list[0].setMouseSensitive(true);
      major_list[0].getSize()[0] = 400;
      major_list[0].getSize()[1] = 20;
      major_list[0].getPosition()[2] = .5f;
      major_list[0].getPosition()[3] = .5f;
      major_list[0].getOffset()[2] = -.5f;
      major_list[0].getOffset()[3] = -.5f;
      major_chooser.add(major_list[0]);
      
      final Frame name_label = new Frame();
      name_label.getSize()[0] = 400;
      name_label.getSize()[1] = 50;
      name_label.getPosition()[2] = .5f;
      name_label.getPosition()[3] = .5f;
      name_label.getOffset()[2] = -.5f;
      name_label.getOffset()[3] = -.5f;
      name_label.setTexture(new Texture("art/white.png"));
      name_label.setTextAlign(LEFT,CENTER);
      name_label.setTextColor(color(0));
      name_label.setTextFont(createFont("comic sans ms",20));
      name_label.setText("");
      name_chooser.add(name_label);
      
      final Frame name_asker = new Frame();
      name_asker.getSize()[0] = 700;
      name_asker.getSize()[1] = 30;
      name_asker.getPosition()[1] = -300;
      name_asker.getPosition()[2] = .5f;
      name_asker.getPosition()[3] = .5f;
      name_asker.getOffset()[2] = -.5f;
      name_asker.getOffset()[3] = -.5f;
      name_asker.setTexture(new Texture("art/white.png"));
      name_asker.setTextAlign(LEFT,CENTER);
      name_asker.setTextColor(color(0));
      name_asker.setTextFont(createFont("comic sans ms",20));
      name_asker.setText("plz type ur name haha gottem");
      name_chooser.add(name_asker);
      
      final Frame major_asker = new Frame();
      major_asker.getSize()[0] = 700;
      major_asker.getSize()[1] = 30;
      major_asker.getPosition()[1] = -300;
      major_asker.getPosition()[2] = .5f;
      major_asker.getPosition()[3] = .5f;
      major_asker.getOffset()[2] = -.5f;
      major_asker.getOffset()[3] = -.5f;
      major_asker.setTexture(new Texture("art/white.png"));
      major_asker.setTextAlign(LEFT,CENTER);
      major_asker.setTextColor(color(0));
      major_asker.setTextFont(createFont("comic sans ms",20));
      major_asker.setText("plz choose ur major haha gottem");
      major_chooser.add(major_asker);
      
      char[] alphabet = "abcdefghijklmnopqrstuvwxyz".toCharArray();
      for(int i=0;i<alphabet.length;i++) {
        final char c = alphabet[i];
        int x = i%10;
        int y = i/10;
        final Frame letter = new Frame(){
          public void draw(float x, float y, float w, float h) {
            super.draw(x,y,w,h);
            if(mousePressing() && mouseHovering()) {
              name_label.setText(name_label.text+c);
              global_resources.put("name",name_label.text);
            }
          }
        };
        letter.setMouseSensitive(true);
        letter.getSize()[0] = 30;
        letter.getSize()[1] = 30;
        letter.getPosition()[0] = -300+x*30;
        letter.getPosition()[1] = -200+y*30;
        letter.getPosition()[2] = .5f;
        letter.getPosition()[3] = .5f;
        letter.setTexture(new Texture("art/def.png"));
        letter.setTextAlign(CENTER,CENTER);
        letter.setTextColor(color(0));
        letter.setTextFont(createFont("comic sans ms",14));
        letter.setText(c+"");
        name_chooser.add(letter);
      }
      
      final int[] points_left = new int[]{50};
      final Frame point_left_counter = new Frame();
      point_left_counter.getPosition()[0] = 200;
      point_left_counter.getPosition()[1] = 40;
      point_left_counter.setTextAlign(LEFT,TOP);
      point_left_counter.setTextColor(color(0));
      point_left_counter.setTextFont(createFont("courier new bold",12));
      point_left_counter.setText("points left: 50");
      stats.add(point_left_counter);
      for(int i=0;i<2;i++) {
      for(int j=0;j<5;j++) {
        final int[] value = new int[1];
        final Frame stat = new Frame();
        stat.getPosition()[0] = 44+i*144;
        stat.getPosition()[1] = 106+j*52;
        stat.getSize()[0] = 23;
        stat.getSize()[1] = 23;
        stat.setTextAlign(LEFT,CENTER);
        stat.setTextColor(color(0));
        stat.setTextFont(createFont("papyrus",12));
        stat.setText("0");
        stats.add(stat);
        final Frame add = new Frame(){
          public void draw(float x, float y, float w, float h) {
            super.draw(x,y,w,h);
            if(mousePressing() && mouseHovering()) {
              if(points_left[0]>0) {
                points_left[0]--;
                value[0]++;
                stat.setText(value[0]+"");
                point_left_counter.setText("points left: "+points_left[0]);
              }
            }
          }
        };
        add.setMouseSensitive(true);
        add.getPosition()[0] = 100+i*144;
        add.getPosition()[1] = 106+j*52;
        add.getSize()[0] = 23;
        add.getSize()[1] = 11;
        add.setTextAlign(LEFT,CENTER);
        add.setTextColor(color(0));
        add.setTextFont(createFont("papyrus",12));
        add.setText("+");
        stats.add(add);
        final Frame sub = new Frame(){
          public void draw(float x, float y, float w, float h) {
            super.draw(x,y,w,h);
            if(mousePressing() && mouseHovering()) {
              if(points_left[0]<50 && value[0]>0) {
                points_left[0]++;
                value[0]--;
                stat.setText(value[0]+"");
                point_left_counter.setText("points left: "+points_left[0]);
              }
            }
          }
        };
        sub.setMouseSensitive(true);
        sub.getPosition()[0] = 100+i*144;
        sub.getPosition()[1] = 117+j*52;
        sub.getSize()[0] = 23;
        sub.getSize()[1] = 11;
        sub.setTextAlign(LEFT,CENTER);
        sub.setTextColor(color(0));
        sub.setTextFont(createFont("papyrus",12));
        sub.setText("-");
        stats.add(sub);
      }
      }
      
      overlay.add(choosers[0]);
    }
    
    public void run() {
      super.run();
      if(mousePressing()) {
        bgm0.setGain(0);
        bgm.setGain(-1000000);
        new Thread(new Runnable(){public void run(){
          try {
            Thread.sleep(200);
          } catch(Exception e) {}
          bgm0.setGain(-100000);
          bgm.setGain(0);
        }}).start();
      }
    }
    
  };
  
}

public void loadCredits() {
  
  credits = new Screen(){
    
    public String[] roles = new String[]{
      "programmer",
      "graphic artist",
      "sound artist",
      "that one \"ideas guy\"",
      "culinary expert",
      "director",
      "voice actor",
      "visionary",
      "idk lmao",
      "former child",
      "producer",
      "contributor",
      "backer",
      "sponsor",
      "ur mum haha gottem",
      "biologist",
      "mathematician",
      "programatoristorician",
      "graphicical \"artist\"",
      "the person who makes all the sounds",
      "the business major who actually didn't do anything",
      "that water bottle in the corner of the table",
      "professional memer",
      "micheal from vsauce",
      "visionary",
    };
    
    public String[] names = FileIO.read(sketchPath()+"/data/namelist.txt").split("\n");
    
    public ArrayList<String> l_roll = new ArrayList<String>();
    public ArrayList<String> r_roll = new ArrayList<String>();
    
    public void init() {
      
      bgm.pause();
      bgm.close();
      bgm = minim.loadFile("sound/on the banks of the old raritan loud.mp3",4096);
      bgm.loop();
      
      final Frame overlay = new Frame();
      overlay.getSize()[2] = 1;
      overlay.getSize()[3] = 1;
      overlay.setTexture(new Texture(sketchPath()+"/data/art/black.png"));
      base.add(overlay);
      
      final Frame r = new Frame(){
        public void draw(float x, float y, float w, float h) {
          super.draw(x,y,w,h);
          setAngle(random(-.02f,.02f));
        }
      };
      r.getPosition()[2] = .5f;
      r.getPosition()[3] = .5f;
      r.getPivot()[2] = .5f;
      r.getPivot()[3] = .5f;
      r.getOffset()[2] = -.5f;
      r.getOffset()[3] = -.5f;
      r.setTexture(new Texture(sketchPath()+"/data/art/icons/rutgersR.png"));
      overlay.add(r);
      
      final float[] tracker = new float[1];
      Tasks.add(new FloatMover(0,1,.001f){
        public void apply(){
          tracker[0] = get();
          r.getSize()[2] = get();
          r.getSize()[3] = get();
          bgm.setGain(10*log(get()));
        }
        public void onFinish() {
          Tasks.clear();
          Tasks.add(title_screen);
        }
      });
      
      final Frame text_roll = new Frame(){
        public void draw(float x, float y, float w, float h) {
          super.draw(x,y,w,h);
          
          for(int i=0;i<4;i++) {
            l_roll.add(roles[(int)random(0,roles.length)]);
            r_roll.add(names[(int)random(0,names.length)]);
          }
          while(l_roll.size()>100) {
            l_roll.remove(0);
            r_roll.remove(0);
          }
          fill(255,255*(1-tracker[0]));
          for(int i=0;i<l_roll.size();i++) {
            textAlign(LEFT,TOP);
            text(l_roll.get(i),x+100,y+i*20);
            textAlign(RIGHT,TOP);
            text(r_roll.get(i),x+w-100,y+i*20);
          }
          
        }
      };
      text_roll.getSize()[2] = 1;
      text_roll.getSize()[3] = 1;
      overlay.add(text_roll);
      
    }
    
    public void run() {
      super.run();
      fill(255);
      textAlign(CENTER,TOP);
      text("thx 4 playing the demo",width/2,14);
    }
    
  };
  
}

public void loadGameplay() {
  
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
      player.drag = .01f;
      player.friction = .5f;
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
      walking.speed = .25f;
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

public void loadSplashScreen() {
  
  splash_screen = new Screen() {
    
    public void init() {
      
      final float[] opacity = new float[1];
      final Frame overlay = new Frame() {
        public void draw(float x, float y, float w, float h) {
          fill(opacity[0]);
          rect(x,y,w,h);
          super.draw(x,y,w,h);
        }
      };
      overlay.getSize()[2] = 1;
      overlay.getSize()[3] = 1;
      overlay.setTextAlign(CENTER,CENTER);
      overlay.setTextFont(createFont("comic sans ms",72));
      overlay.setText("survie the rutger coleg 1");
      overlay.setTextColor(color(0));
      base.add(overlay);
      
      Tasks.add(new FloatMover(0,300,3){
        public void init() {
          setType(LINEAR);
        }
        public void apply() {
          opacity[0] = get();
        }
        public void onFinish() {
          Tasks.add(new FloatMover(255,-30,3){
            public void init() {
              setType(LINEAR);
            }
            public void apply() {
              opacity[0] = get();
            }
            public void onFinish() {
              Tasks.remove(splash_screen);
              Tasks.add(title_screen);
            }
          });
        }
      });
      
    }
    
  };
  
}

public void loadTitleScreen() {
  
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
      setting_screen.getPosition()[2] = 1.5f;
      setting_screen.getPosition()[3] = .5f;
      setting_screen.getOffset()[2] = -.5f;
      setting_screen.getOffset()[3] = -.5f;
      setting_screen.setTexture(new Texture("art/def.png"));
      final Frame slider = new Frame();
      slider.getSize()[0] = 100;
      slider.getSize()[1] = 10;
      slider.getPosition()[2] = .5f;
      slider.getPosition()[3] = .5f;
      slider.getOffset()[2] = -.5f;
      slider.getOffset()[3] = -.5f;
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
              
              Tasks.add(new FloatMover(-1,0,.05f){
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
      deeprut.getPosition()[2] = .5f;
      deeprut.getOffset()[2] = -.5f;
      deeprut.setTexture(new Texture("art/icons/deeprut.png"));
      overlay.add(deeprut);
      
      final Frame button_base = new Frame();
      button_base.getSize()[0] = 400;
      button_base.getSize()[1] = 200;
      button_base.getPosition()[2] = .5f;
      button_base.getPosition()[3] = .5f;
      button_base.getOffset()[2] = -.5f;
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
                      
                      Tasks.add(new FloatMover(0,-1,.1f){
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
          buttons[i].getSize()[3] = 1.f/buttons.length;
          buttons[i].getPosition()[2] = .5f;
          buttons[i].getPosition()[1] = 10;
          buttons[i].getOffset()[2] = -.5f;
          buttons[i].getOffset()[3] = i*1.09f;
          buttons[i].setTexture(new Texture("art/def.png"));
          button_base.add(buttons[i]);
        }
      }
      overlay.add(button_base);
      
    }
  };
  
}

public void loadTuition() {
  
  tuition = new Screen(){
    
    public void init() {
      
      Frame frame = new Frame(){
        public void draw(float x, float y, float w, float h) {
          super.draw(x,y,w,h);
          if(mousePressing() && mouseHover()) {
            Tasks.remove(tuition);
            Tasks.add(credits);
          }
        }
      };
      frame.setMouseSensitive(true);
      frame.getSize()[2] = 1;
      frame.getSize()[3] = 1;
      frame.setTexture(new Texture(sketchPath()+"/data/art/background/tution.png"));
      base.add(frame);
      
      Frame pay_button = new Frame(){
        public void draw(float x, float y, float w, float h) {
          super.draw(x,y,w,h);
          getPosition()[0] = mouseX;
          getPosition()[1] = mouseY;
        }
      };
      pay_button.getSize()[0] = 250;
      pay_button.getSize()[1] = 100;
      pay_button.getOffset()[2] = -.5f;
      pay_button.getOffset()[3] = -.5f;
      //pay_button.setTextAlign(CENTER,CENTER);
      //pay_button.setText("PAY UR BILL");
      //pay_button.setTextFont(createFont("comic sans ms",24));
      pay_button.setTexture(new Texture("art/icons/pay up.png"));
      frame.add(pay_button);
    }
    
  };
  
}
  public void settings() {  size(1280,840);  noSmooth(); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "efrf23frttFu" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
