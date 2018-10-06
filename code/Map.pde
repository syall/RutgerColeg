
public class Map extends Frame {
  
  public class Platform extends Frame {
    
    private int type;
    public static final int SOLID = 0;
    public static final int LEDGE = 1;
    public static final int AIR = 2;
    public static final int FALLING = 3;
    public static final int SWIMMABLE = 4;
    
  }
  
  private ArrayList<Platform> platforms = new ArrayList<Platform>();
  
  public Map(String path) {
    InfoTree info = new InfoTree(path);
    println(info.toString());
  }
  
}
