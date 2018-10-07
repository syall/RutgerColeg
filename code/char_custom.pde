
void loadCharacterCustomization() {
  
  char_custom = new Screen(){
    
    public Frame look_chooser;
    public Frame major_chooser;
    public Frame stat_chooser;
    
    public void init() {
      
      if(bgm!=null) {
        bgm.pause();
        bgm.close();
      }
      bgm = minim.loadFile("sound/music/alma.mp3");
      bgm.play();
      
      base.setTexture(new Texture("art/background/hc.jpg"));
      final Frame overlay = new Frame();
      overlay.getSize()[2] = 1;
      overlay.getSize()[3] = 1;
      base.add(overlay);
      
      final FloatMover overlay_x = new FloatMover(0,0,.2){
        public void init() {
          setType(EASE);
        }
        public void apply() {
          overlay.getPosition()[2] = get();
        }
      };
      Tasks.add(overlay_x);
      
      look_chooser = new Frame();
      major_chooser = new Frame();
      stat_chooser = new Frame();
      final Frame[] choosers = new Frame[]{look_chooser,major_chooser,stat_chooser};
      
      for(int i=0;i<choosers.length;i++) {
        final int next_index = (i+1)%choosers.length;
        Frame frame = choosers[i];
        frame.getSize()[0] = -70;
        frame.getSize()[1] = -70;
        frame.getSize()[2] = 1;
        frame.getSize()[3] = 1;
        frame.getPosition()[2] = .5+i;
        frame.getPosition()[3] = .5;
        frame.getOffset()[2] = -.5;
        frame.getOffset()[3] = -.5;
        frame.setTexture(new Texture("art/def.png"));
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
          frame.add(next);
        }
      }
      
      final Frame stats = new Frame();
      stats.getSize()[2] = .6;
      stats.getSize()[3] = 1;
      stats.setTexture(new Texture("art/background/stats.png"));
      choosers[2].add(stats);
      
      final Frame look_frame = new Frame();
      look_frame.getSize()[0] = 476;
      look_frame.getSize()[1] = 670;
      look_frame.getPosition()[3] = .5;
      look_frame.getPosition()[0] = 70;
      look_frame.getOffset()[3] = -.5;
      look_frame.setTexture(new Texture("art/def.png"));
      
      String[] parts = new String[]{
          "art/model/skin.anim",
          "art/model/shoes.anim",
          "art/model/pants.anim",
          "art/model/shirts.anim",
          "art/model/hair.anim"};
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
        switcher.getSize()[0] = 50;
        switcher.getSize()[1] = 20;
        switcher.getPosition()[0] = 100;
        switcher.getPosition()[1] = -100*i-100;
        switcher.getPosition()[2] = 1;
        switcher.getPosition()[3] = 1;
        switcher.setTexture(new Texture("art/def.png"));
        look_frame.add(switcher);
      }
      
      choosers[0].add(look_frame);
      
      final String[] lines = FileIO.read(sketchPath()+"/data/majors.txt").split("\n");
      final int line_count = 15;
      final int[] line_scroll = new int[1];
      final Frame major_list_dropdown = new Frame(){
        public void draw(float x, float y, float w, float h) {
          super.draw(x,y,w,h);
          if(mouseHovering()) {
            line_scroll[0] += scroll;
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
      major_list_dropdown.setTexture(new Texture("art/def.png"));
      final Frame major_list = new Frame(){
        
        public void draw(float x, float y, float w, float h) {
          super.draw(x,y,w,h);
          if(mousePressing() && mouseHovering()) {
            major_list_dropdown.visible = !major_list_dropdown.visible;
          }
        }
        
      };
      major_list.setTexture(new Texture("art/def.png"));
      major_list_dropdown.visible = false;
      major_list.setTextColor(color(0));
      major_list.setTextAlign(LEFT,CENTER);
      major_list.setTextFont(createFont("courier new bold",12));
      major_list.setText(lines[0]);
      major_list.add(major_list_dropdown);
      major_list.setMouseSensitive(true);
      major_list.getSize()[0] = 400;
      major_list.getSize()[1] = 20;
      major_list.getPosition()[2] = .5;
      major_list.getPosition()[3] = .5;
      major_list.getOffset()[2] = -.5;
      major_list.getOffset()[3] = -.5;
      choosers[1].add(major_list);
      
      overlay.add(choosers[0]);
    }
    
  };
  
}
