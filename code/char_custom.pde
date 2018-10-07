
void loadCharacterCustomization() {
  
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
      
      final FloatMover overlay_x = new FloatMover(0,0,.2){
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
        frame.getPosition()[2] = .5+i;
        frame.getPosition()[3] = .5;
        frame.getOffset()[2] = -.5;
        frame.getOffset()[3] = -.5;
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
      stats.getPosition()[3] = .5;
      stats.getOffset()[3] = -.5;
      stats.getPosition()[2] = .5;
      stats.getOffset()[2] = -.5;
      stats.setTexture(new Texture("art/background/stats.png"));
      stat_chooser.add(stats);
      
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
      major_list[0].getPosition()[2] = .5;
      major_list[0].getPosition()[3] = .5;
      major_list[0].getOffset()[2] = -.5;
      major_list[0].getOffset()[3] = -.5;
      major_chooser.add(major_list[0]);
      
      final Frame name_label = new Frame();
      name_label.getSize()[0] = 400;
      name_label.getSize()[1] = 50;
      name_label.getPosition()[2] = .5;
      name_label.getPosition()[3] = .5;
      name_label.getOffset()[2] = -.5;
      name_label.getOffset()[3] = -.5;
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
      name_asker.getPosition()[2] = .5;
      name_asker.getPosition()[3] = .5;
      name_asker.getOffset()[2] = -.5;
      name_asker.getOffset()[3] = -.5;
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
      major_asker.getPosition()[2] = .5;
      major_asker.getPosition()[3] = .5;
      major_asker.getOffset()[2] = -.5;
      major_asker.getOffset()[3] = -.5;
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
        letter.getPosition()[2] = .5;
        letter.getPosition()[3] = .5;
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
