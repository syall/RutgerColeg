
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
            value[index] = xi+(sin(angle)*.5+.5)*(xf-xi);
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
            value[index] = xi+(xf-xi)*(sin(time)*.5+.5);
          break;
          case TRIANGLE:
            time += rate;
            
          break;
        }
      }
    }
    
  }
  
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
  
}
