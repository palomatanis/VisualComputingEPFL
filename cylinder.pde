class Cylinders {
    ArrayList<PVector> cylinderList; 
    float cylinderBaseSize = 30;
    float cylinderHeight = 50;
    float cylinderPosition;
    int cylinderResolution = 40;
    
    PShape openCylinder;
    PShape closeCylinder;
    
    Cylinders() {
      // Collection of Cylinders
       cylinderList = new ArrayList<PVector>();
       openCylinder = new PShape();
       closeCylinder = new PShape();
       

    }
    
    void setupCylinder(float t, float heightCylinder) {
      //Resize cylinder according to size of panel
       cylinderBaseSize = cylinderBaseSize * t;
       cylinderHeight = cylinderHeight * t;
       cylinderPosition = heightCylinder; 
       
      float angle;
      float[] x = new float[cylinderResolution + 1];
      float[] y = new float[cylinderResolution + 1];
      
      //get the x and y position on a circle for all the sides
      for(int i = 0; i < x.length; i++) {
          angle = (TWO_PI / cylinderResolution) * i;
          x[i] = sin(angle) * cylinderBaseSize;
          y[i] = cos(angle) * cylinderBaseSize;
      }
      openCylinder = createShape();
      openCylinder.beginShape(QUAD_STRIP);
      
      //draw the border of the cylinder
      for(int i = 0; i < x.length; i++) {
          openCylinder.vertex(x[i], y[i] , 0);
          openCylinder.vertex(x[i], y[i], cylinderHeight);
      }
      openCylinder.endShape();
      
      closeCylinder = createShape();
       closeCylinder.beginShape(TRIANGLES);
       for(int i = 0; i < x.length-1; ++i) {
          // Bottom lid
          closeCylinder.vertex(x[i], y[i], 0);
          closeCylinder.vertex(x[i+1], y[i+1], 0);
          closeCylinder.vertex(0,0,0);
          
          //Top lid
          closeCylinder.vertex(x[i], y[i], cylinderHeight);
          closeCylinder.vertex(x[i+1], y[i+1], cylinderHeight);
          closeCylinder.vertex(0,0,cylinderHeight);
       } 
      closeCylinder.endShape();
    }
    
    void drawCylinders(boolean shiftPressed){
      
      if(shiftPressed){
        for (PVector cylinder : cylinderList){
          pushMatrix();
          translate(cylinder.x,cylinder.y);
          openCylinder.setFill(color(158,112,32));
          closeCylinder.setFill(color(168,136,72));

          shape(openCylinder);
          shape(closeCylinder);
          popMatrix();
        }
      }
      else {
        for (PVector cylinder : cylinderList){
          //fill(178,146,82);
          fill(204,102,0);
          pushMatrix();
          
          //Define well the height
          translate(cylinder.x,cylinderPosition * 1.4 ,cylinder.y);
          rotateX(PI/2);
          shape(openCylinder);
          shape(closeCylinder);
          popMatrix();
        }
      }
      
    }
    
    boolean overlapCheck(int x, int y) {
      for(PVector cylinder : cylinderList){
        if(dist (x, y, cylinder.x, cylinder.y) < 2*cylinderBaseSize)
          return false;
      }
      return true;
    }
    
    void addCylinderAt(int x, int y) {
        this.cylinderList.add(new PVector(x, y));
      
    }
}