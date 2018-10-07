
class Ray {
  
  public class IntersectionInfo {
    
    private float t0; // the ray
    private float t1; // the surface
    private float[] position;
    private int[] element;
    
    public IntersectionInfo(float t0, float t1, float[] position) {
      this.t0 = t0;
      this.t1 = t1;
      this.position = position;
    }
    
  }
  
  public float x;
  public float y;
  public float dx;
  public float dy;
  
  public IntersectionInfo findIntersection(float[] v0, float[] v1) {
    
    float a = v0[0];
    float b = v0[1];
    float da = v1[0]-a;
    float db = v1[1]-b;
    
    float det = da*dy-db*dx;
    if(det!=0) {
      float t0 = (db*(x-a)-da*(y-b))/det;
      float t1 = (dy*(x-a)-dx*(y-b))/det;
      if(t0>=0 && t1>=0 && t1<=1) {
        return new IntersectionInfo(t0,t1,new float[]{
            ((x+dx*t0)+(a+da*t1))/2,
            ((y+dy*t0)+(b+db*t1))/2});
      }
    }
    
    return null;
  }
  
}
