import ddf.minim.*;

public boolean pmousePressed;
public boolean[] key_input = new boolean[256];

public boolean mousePressing() {
  return mousePressed && !pmousePressed;
}

public boolean mouseReleasing() {
  return !mousePressed && pmousePressed;
}

public Screen title_screen;
public Screen char_custom;
public Screen gameplay;
public Screen credits;

public Minim minim;
public AudioPlayer bgm;

void setup() {
  
  size(1280,840);
  noSmooth();
  
  minim = new Minim(this);
  
  surface.setTitle("survie the rutger coleg 1");
  surface.setIcon(createImage(1,1,ARGB));
  
  loadTitleScreen();
  loadCharacterCustomization();
  loadGameplay();
  credits = new Screen(){
    public void init() {
      
    }
  };

  Tasks.add(title_screen);
}

void keyPressed() {
  key_input[keyCode] = true;
}

void keyReleased() {
  key_input[keyCode] = false;
}

void draw() {
  
  Tasks.handle();
  pmousePressed = mousePressed;
}
