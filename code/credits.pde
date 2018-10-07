
void loadCredits() {
  
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
      bgm.play();
      
      final Frame overlay = new Frame();
      overlay.getSize()[2] = 1;
      overlay.getSize()[3] = 1;
      overlay.setTexture(new Texture(sketchPath()+"/data/art/black.png"));
      base.add(overlay);
      
      final Frame r = new Frame(){
        public void draw(float x, float y, float w, float h) {
          super.draw(x,y,w,h);
          setAngle(random(-.02,.02));
        }
      };
      r.getPosition()[2] = .5;
      r.getPosition()[3] = .5;
      r.getPivot()[2] = .5;
      r.getPivot()[3] = .5;
      r.getOffset()[2] = -.5;
      r.getOffset()[3] = -.5;
      r.setTexture(new Texture(sketchPath()+"/data/art/icons/rutgersR.png"));
      overlay.add(r);
      
      final float[] tracker = new float[1];
      Tasks.add(new FloatMover(0,1,.001){
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
            text(l_roll.get(i),x+4,y+i*20);
            textAlign(RIGHT,TOP);
            text(r_roll.get(i),x+w-4,y+i*20);
          }
          
        }
      };
      text_roll.getSize()[2] = 1;
      text_roll.getSize()[3] = 1;
      overlay.add(text_roll);
      
    }
    
  };
  
}
