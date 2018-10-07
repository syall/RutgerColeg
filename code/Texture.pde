
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
