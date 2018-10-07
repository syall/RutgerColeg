
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
        value = start+(end-start)*(sin(time)*.5+.5);
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
