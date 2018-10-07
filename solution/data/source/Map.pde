
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
      overlay.getPosition()[0] += (min(0,-entities.get(0).getPosition()[0]+width/2)-overlay.getPosition()[0])*.2;
      overlay.getPosition()[1] += (min(0,-entities.get(0).getPosition()[1]+height/2+200)-overlay.getPosition()[1])*.2;
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
