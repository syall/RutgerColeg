
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
