import java.io.*;

static class FileIO {
  
  public static String read(String path) {
    try {
      BufferedReader in = new BufferedReader(
          new InputStreamReader(
          new FileInputStream(path),"UTF8"));
      StringBuilder text = new StringBuilder();
      String line = null;
      while((line=in.readLine())!=null) {
        text.append(line);
        text.append("\n");
      }
      in.close();
      return text.toString();
    } catch(IOException e) {}
    return null;
  }
  
  public static String getExtension(String path) {
    return path.substring(path.lastIndexOf(".")+1).toLowerCase().trim();
  }
  
  public static String getDirectory(String path) {
    return path.substring(0,path.lastIndexOf("/")+1);
  }
  
}
