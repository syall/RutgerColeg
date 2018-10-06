
class InfoTree {
  
  class Node extends ArrayList<Node> {
    
    private Node parent;
    private String name;
    private String[] text;
    
    public void setParent(Node node) {
      node.add(this);
      parent = node;
    }
    
    public Node getParent() {
      return parent;
    }
    
    public void setName(String value) {
      name = value;
    }
    
    public String getName() {
      return name;
    }
    
    public void setText(String[] value) {
      text = value;
    }
    
    public String[] getText() {
      return text;
    }
    
    public Node getChild(String name) {
      for(Node node : this) {
        if(name.equals(node.getName())) {
          return node;
        }
      }
      return null;
    }
    
    public String toString() {
      StringBuilder str = new StringBuilder();
      if(getName()!=null) {
        str.append(getName());
      }
      str.append(" : ");
      if(size()>0) {
        str.append(" {\n");
        for(Node node : this) {
          str.append(node.toString());
        }
        str.append("}");
      } else if(getText()!=null) {
        if(getName()!=null) {
          str.append(" ");
        }
        for(int i=0;i<getText().length;i++) {
          if(i>0) {
            str.append(" , ");
          }
          str.append(getText()[i]);
        }
      }
      str.append("\n");
      return str.toString();
    }
    
    public int indexOf(Node node) {
      for(int i=0;i<size();i++) {
        if(get(i)==node) {
          return i;
        }
      }
      return -1;
    }
    
    public ArrayList<Node> getDescendants() {
      ArrayList<Node> descendants = new ArrayList<Node>();
      descendants.addAll(this);
      for(int i=0;i<descendants.size();i++) {
        descendants.addAll(descendants.get(i));
      }
      return descendants;
    }
    
  }
  
  private Node root;
  
  public InfoTree(String path) {
    
    root = new Node();
    Node node = root;
    
    String text = FileIO.read(path);
    if(text!=null) {
      
      StringBuilder name = new StringBuilder();
      for(int i=0;i<text.length();i++) {
        char c = text.charAt(i);
        if(c=='{') {
          Node next = new Node();
          if(!name.toString().trim().isEmpty()) {
            next.setName(name.toString().trim());
            name.setLength(0);
          }
          next.setParent(node);
          node = next;
        } else if(c=='}') {
          if(!name.toString().trim().isEmpty()) {
            Node last = new Node();
            last.setName(name.toString().trim());
            name.setLength(0);
            last.setParent(node);
          }
          node = node.getParent();
        } else {
          name.append(c);
        }
      }
      
    }
    
  }
  
  public Node get(String path) {
    Node node = root;
    String[] path_split = path.split("\\.");
    for(int i=0;i<path_split.length;i++) {
      node = node.getChild(path_split[i]);
      if(node==null) {
        return null;
      }
    }
    return node;
  }
  
  public String toString() {
    StringBuilder str = new StringBuilder();
    for(Node node : root) {
      str.append(node.toString());
    }
    return str.toString();
  }
  
  public ArrayList<Node> getDescendants() {
    return root.getDescendants();
  }
  
}
