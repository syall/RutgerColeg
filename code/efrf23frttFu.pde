import ddf.minim.*;

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

void setup() {
  
  size(1280,840);
  noSmooth();
  
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

void keyPressed() {
  key_input[keyCode] = true;
}

void keyReleased() {
  key_input[keyCode] = false;
}

void mouseWheel(MouseEvent e) {
  scroll = e.getCount();
}

void draw() {
  
  Tasks.handle();
  pmousePressed = mousePressed;
  
  for(int i=sfx.size()-1;i>=0;i--) {
    if(!sfx.get(i).isPlaying()) {
      sfx.remove(i);
    }
  }
  
  scroll = 0;
}
