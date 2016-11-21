import java.util.Random;
import processing.video.*;

class ImageProcessing extends PApplet {

  PImage img, temp, result;
  public Movie cam;
  ArrayList<PVector> intersect, lines;
  TwoDThreeD t;
  boolean pres, quadFound;


  void settings() {
    //size(800, 600);
    size(640, 480);
    //size(815, 240);
  }

  void setup() {
    pres = false;
    /***** For static image *****/
    /*img = loadImage("/Users/manishthani/Desktop/Final_v2/board6.png");
    temp = createImage(img.width, img.height, RGB);
    result = createImage(img.width, img.height, RGB);*/

    /***** For camera *****/
    //cam = new Capture (this, cameras[63]);
    //cam.start();

    /***** For video *****/
    //cam = new Movie(this, "/Users/manishthani/Desktop/Final/testvideo.mp4");
    cam = new Movie(this, "/home/paloma/Escritorio/final_v2/testvideo.mp4");
    cam.loop();
 
    if (cam.available()) {
      cam.read();
    } 
    img = cam.get();

    temp = createImage(cam.width, cam.height, RGB);
    result = createImage(cam.width, cam.height, RGB);
  }

  void draw() {
    quadFound = false;
    cam.loadPixels();
    if (cam.available()) {
      cam.read();
    } 
    img = cam.get();
    cam.updatePixels();
    
    image (img, 0, 0);
    //println (cam.time());
    ///cam.loadPixels();
    ///loadPixels();
    //img = cam;
    //image(cam, 0, 0);



    /***** For video (comment section for static images)*****/
    //img = cam.get();

    thresholding(img); // save in temp
    blur(temp); // save in result
    sobel(result);
    image(temp, 0, 0);
    t = new TwoDThreeD(800, 600);
    lines = hough(temp);
    boolean goOn = false;

    if (lines.size() > 3) {
      goOn = true;
      intersect = getIntersections(lines);
      if (intersect.size() > 3){
        for (int i = 0; i < intersect.size(); i++) {
          if (intersect.get(i).x > img.width || intersect.get(i).y > img.height)
            goOn = false;
        }
      }
      else goOn = false;
      println (lines.size());
    }


    if (goOn) {  
      println( intersect.size());

      // Selection of quads

      QuadGraph graph = new QuadGraph();
      graph.build(lines, width, height);
      List<int[]> quads = graph.findCycles();
      //float maxArea = 0;
      if (quads.size() > 0) {
        ArrayList<PVector> newIntersections = new ArrayList<PVector> ();
        for (int[] quad : quads) {
          
          List<PVector> quadSorted = new ArrayList<PVector>();
          quadSorted.add(intersect.get(quad[0]));
          quadSorted.add(intersect.get(quad[1]));
          quadSorted.add(intersect.get(quad[2]));
          quadSorted.add(intersect.get(quad[3]));
          println ("FOR");
          //for ( int i = 0; i < 4; ++i) {
          //  println("CORNERS BEFORE --> " + i + " = " + quadSorted.get(i).x + " " + quadSorted.get(i).y);
          //}
          quadSorted = graph.sortCorners(quadSorted);
          //for ( int i = 0; i < 4; ++i) {
          //  println("CORNERS AFTER --> " + i + " = " + quadSorted.get(i).x + " " + quadSorted.get(i).y);
          //}
          PVector num1 = quadSorted.get(0);
          PVector num2 = quadSorted.get(1);
          PVector num3 = quadSorted.get(2);
          PVector num4 = quadSorted.get(3);
          
          if (graph.isConvex(num1, num2, num3, num4) && graph.nonFlatQuad(num1, num2, num3, num4)) {
          
          //float area = graph.validArea(quadSorted.get(0), quadSorted.get(1), quadSorted.get(2), quadSorted.get(3), 2*width+2*height, (2*width+2*height)/10);
          //if ((area > 0) && (area > maxArea)) {
            //maxArea = area;
            // (intersection() is a simplified version of the
            // intersections() method you wrote last week, that simply
            // return the coordinates of the intersection between 2 lines)
            println("ENTRAAA");
            //ArrayList<PVector> l12 = new ArrayList<PVector>();
            //l12.add(quadSorted.get(0));
            //l12.add(quadSorted.get(1));

            //ArrayList<PVector> l23 = new ArrayList<PVector>();
            //l23.add(quadSorted.get(1));
            //l23.add(quadSorted.get(2));

            //ArrayList<PVector> l34 = new ArrayList<PVector>();
            //l34.add(quadSorted.get(2));
            //l34.add(quadSorted.get(3));

            //ArrayList<PVector> l41 = new ArrayList<PVector>();
            //l41.add(quadSorted.get(3));
            //l41.add(quadSorted.get(0));

            //ArrayList<PVector> c12 = getIntersections(quadSorted);
            //PVector c23 = getIntersections(l23).get(0);
            //PVector c34 = getIntersections(l34).get(0);
            //PVector c41 = getIntersections(l41).get(0);

            newIntersections.clear();
            newIntersections.add(num1);
            newIntersections.add(num2);
            newIntersections.add(num3);
            newIntersections.add(num4);

            // Choose a random, semi-transparent colour
            Random random = new Random();
            fill(color(min(255, random.nextInt(300)), 
              min(255, random.nextInt(300)), 
              min(255, random.nextInt(300)), 50));
            quad(num1.x, num1.y, num2.x, num2.y, num3.x, num3.y, num4.x, num4.y);
            quadFound = true;
          }
        }
        if(newIntersections.size() > 0){
          intersect = newIntersections;
          println("INTER  " + intersect.size());
        }
        else {
          intersect.clear();
        }
      }
    }
  }


  List<PVector> sortCorners(List<PVector> quad) {
    println("sort");
    // Sort corners so that they are ordered clockwise
    PVector a = quad.get(0);
    PVector b = quad.get(2);
    PVector center = new PVector((a.x+b.x)/2, (a.y+b.y)/2);
    java.util.Collections.sort(quad, new CWComparator(center));

    a = quad.get(0);
    b = quad.get(2);
    center = new PVector((a.x+b.x)/2, (a.y+b.y)/2);
    // TODO:
    // Re-order the corners so that the first one is the closest to the
    // origin (0,0) of the image.
    //

    float mag = width * height;
    int pos = 0;
    for ( int i = 0; i < quad.size(); ++i) {
      println("CORNERS BEFORE --> " + i + " = " + quad.get(i).x + " " + quad.get(i).y + " " + quad.get(i).z);
      if (quad.get(i).mag() < mag) {
        pos = i;
        mag = quad.get(i).mag();
      }
    }
    // You can use Collections.rotate to shift the corners inside the quad.
    Collections.rotate(quad, -pos);
   for ( int i = 0; i < quad.size(); ++i) {
      println("CORNERS AFTER --> " + i + " = " + quad.get(i).x + " " + quad.get(i).y + " " + quad.get(i).z);
    }
    
    return quad;
  }

  PVector getRotation() {
    if (!quadFound) {
      return new PVector (0, 0, 0);
    }
    return t.get3DRotations(sortCorners(intersect));
  }

  PImage getVideo() {
    if (cam != null && cam.available()) {
      return cam.copy();
    } else return createImage(width, height, RGB);
  }



  // Gaussian blur

  void blur (PImage img) {
    imgproc.result.loadPixels();
    float[][] kernel = { { 9, 12, 9 }, 
      {12, 15, 12 }, 
      { 9, 12, 9 }};

    float [][] temp =  {{ 0, 0, 0 }, 
      { 0, 0, 0 }, 
      { 0, 0, 0 }};

    //PImage result = createImage(img.width, img.height, ALPHA);
    float count, N = 3;


    float weight = 120.f;

    for (int i = img.width; i < img.width * img.height - img.width; i++) {

      if ((i % img.width != 0) && (i % img.width != img.width-1)) {
        count = 0;

        temp[0][0] = imgproc.brightness(img.pixels[i -img.width -1]) * kernel [0][0]; 
        temp[0][1] = imgproc.brightness(img.pixels[i -img.width]) * kernel [0][1];
        temp[0][2] = imgproc.brightness(img.pixels[i -img.width +1]) * kernel [0][2];
        temp[1][0] = imgproc.brightness(img.pixels[i - 1]) * kernel [1][0];
        temp[1][1] = imgproc.brightness(img.pixels[i]) * kernel [1][1];
        temp[1][2] = imgproc.brightness(img.pixels[i + 1]) * kernel [1][2];
        temp[2][0] = imgproc.brightness(img.pixels[i + img.width -1]) * kernel [2][0];
        temp[2][1] = imgproc.brightness(img.pixels[i + img.width]) * kernel [2][1];
        temp[2][2] = imgproc.brightness(img.pixels[i + img.width +1]) * kernel [2][2];

        for (int j = 0; j < N; j++) {
          for (int k = 0; k < N; k++) {
            count = count + temp[j][k];
          }
        }
        float c = color(count / weight);
        int col = getIntFromColor(c, c, c);
        imgproc.result.pixels[i] = col;
      }
    }
    imgproc.result.updatePixels();
  }

void keyPressed(){
  if(!pres){
    cam.pause();
    pres = true;
  }
  else{
    cam.loop();
    pres = false;
  }
}


  int getIntFromColor(float Red, float Green, float Blue) {
    int R = Math.round(255 * Red);
    int G = Math.round(255 * Green);
    int B = Math.round(255 * Blue);

    R = (R << 16) & 0x00FF0000;
    G = (G << 8) & 0x0000FF00;
    B = B & 0x000000FF;

    return 0xFF000000 | R | G | B;
  }
}