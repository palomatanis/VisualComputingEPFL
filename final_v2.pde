import processing.video.*;

  Mover mover;
  int yMouse = 0;
  int xMouse = 0;
  boolean first = true;
  float angleX = 0;
  float angleZ = 0;
  float rotangleX = 0;
  float rotangleZ = 0;
  float speed = 0.1;
  
  boolean shiftPressed = false;
 

  int screenWidth = 1000;
  int screenHeight = 800;
  
  // Panel atributes
  PGraphics backgroundPanel;
  PGraphics boardPanel;
  PGraphics scorePanel;
  PGraphics barchart;
  PGraphics scrollBarPanel;
  int dataPanelHeight = 190;
  
  // Timer attributes
  int wait = 1000;
  int startTime;
  int time;
  
  // ScrollBar
  HScrollbar scrollBar;
  float positionScrollBar = 1;
  
  FloatList scores;
  
  ImageProcessing imgproc;
  
  void settings() {
    size(screenWidth, screenHeight, P3D);
    startTime = millis();
    scores = new FloatList();
  }
  
  void setup() {
            
    imgproc = new ImageProcessing();
    String []args = {"Image processing window"};
    PApplet.runSketch(args, imgproc);
    
    mover = new Mover();
    backgroundPanel = createGraphics(screenWidth, dataPanelHeight, P2D);
    boardPanel = createGraphics(dataPanelHeight , dataPanelHeight , P2D);
    scorePanel = createGraphics(dataPanelHeight , dataPanelHeight , P2D);
    barchart = createGraphics(dataPanelHeight , dataPanelHeight , P2D);
    scrollBar = new HScrollbar(dataPanelHeight * 3, screenHeight - 25, 400, 20);

   }
  
  
  void draw() {
    PVector rot = imgproc.getRotation();
    if(abs(degrees(rot.x)) < 60 && abs(degrees(rot.z)) < 60 && (rot.x != 0 || rot.z != 0)){
      println(degrees(rot.x) + " " + degrees(rot.y) + " " + degrees(rot.z));
      angleX = rot.x;
      angleZ = rot.z;
    }
    pushMatrix();
    background(255);
    mover.update(angleX,angleZ);
    mover.checkEdges();
    mover.checkCylinderCollision();
    mover.display(shiftPressed);
    popMatrix();
 
    //Data visualization
    pushMatrix();
    drawBackgroundPanel();
    image(backgroundPanel, 0,screenHeight - dataPanelHeight);
    popMatrix();

    pushMatrix();
    drawBoardPanel();
    image(boardPanel, 0,screenHeight - dataPanelHeight);
    popMatrix();
    
    pushMatrix();
    drawScorePanel();
    image(scorePanel, 0, screenHeight - dataPanelHeight);
    popMatrix();
    
    pushMatrix();
    drawBarchart();
    image(barchart, 0, screenHeight - dataPanelHeight);
    popMatrix();
    
    pushMatrix();
    scrollBar.display();
    scrollBar.update();
    popMatrix();
    //println ("Problems");}
    if(imgproc.cam != null && imgproc.cam.available()){
      PImage vid = imgproc.getVideo();
      vid.resize(160,0);
      image(vid, width-160.0,0.0);
    }
  }
  
  void drawBackgroundPanel() {
    backgroundPanel.beginDraw();
    backgroundPanel.background(204,255,204);
    backgroundPanel.endDraw();
  }

  void drawBoardPanel() {
    boardPanel.beginDraw();
    noStroke();
    
    float scale = 0.5;
    int offset = 40;
    scale(scale, scale, scale);
    translate(mover.sizeBoard/2 + offset, screenHeight/scale - mover.sizeBoard/2 - offset,0);
    
    //Draw board
    rectMode(CENTER);
    fill(0,0,102);
    rect(0, 0 , mover.sizeBoard,mover.sizeBoard );
    
    // Draw sphere
    fill(204,204,0);
    ellipse(mover.location.x,mover.location.z ,mover.radius*2,mover.radius*2);
    
    // Draw Cylinders
    fill(255,0,0);
    for (PVector cylinder : mover.cylinders.cylinderList) {
      ellipse(cylinder.x, cylinder.y, mover.cylinders.cylinderBaseSize*2, mover.cylinders.cylinderBaseSize*2);
    }
    boardPanel.endDraw();
  }
  
  void drawScorePanel() {
    scorePanel.beginDraw();

    noFill();
    strokeWeight(4);
    stroke(255,255,255);
    float escala = 0.5;
    scale(0.4, escala, escala);
    float offsetX = mover.sizeBoard*1.5;
    float offsetY = 40;
    translate(mover.sizeBoard/2 + offsetX, screenHeight/escala - mover.sizeBoard/2 - offsetY ,0);
    rect(0, 0 , mover.sizeBoard,mover.sizeBoard );

    // Drawing scores
    textSize(30);
    fill(0,0,0);
    text("Total Score", -140,-100,0);
    text(mover.totalScore, -140,-55,0);
    
    
    text("Velocity", -140, -10, 0);
    text(mover.velocityScore, -140, 35,0);
    
    text("Last Score", -140, 80, 0);
    text(mover.lastScore, -140,125, 0);
    
    scorePanel.endDraw();
  }
  
  void drawBarchart() {
    barchart.beginDraw();
    barchart.background(204,255,204);
    // Draw your shapes
    float offsetX = 20;
    float offsetY = 53;
    noStroke();
    fill(255, 255, 255, 100);
  
    float x = ((screenWidth + (2 * dataPanelHeight))/2) - 2 * offsetX;
    float y =  screenHeight - mover.sizeBoard/2 - offsetY + dataPanelHeight/2;
    
    float sizeBackgroundX = screenWidth - 2*dataPanelHeight + 2 * offsetX;
    float sizeBackgroundY = dataPanelHeight * 3/4;
    translate (x, y);
    rect (0, 0 ,sizeBackgroundX , sizeBackgroundY);
    
    time = millis();
    if (time - startTime >= wait) { 
      scores.append(mover.totalScore);
      startTime = time;
    }
        
    drawScores(sizeBackgroundX, sizeBackgroundY );
    barchart.endDraw();
  }
  

  
  void drawScores(float sizeBackgroundX, float sizeBackgroundY) {
    float rectDimX = 8 * (scrollBar.getPos() + 0.3);
    float rectDimY = 8;
    float nextScorePositionX = -sizeBackgroundX / 2 + rectDimX/2;
    float distBetweenRect = 1;
    float limitScores = floor(sizeBackgroundX / (rectDimX + distBetweenRect)); 
    
    
    while (scores.size() > limitScores) {
      scores.remove(0);
    }
    for (float score : scores){
      drawScore(score, rectDimX, rectDimY,distBetweenRect, nextScorePositionX, sizeBackgroundY);
      nextScorePositionX += rectDimX + distBetweenRect;   
    }
    
  }
  void drawScore(float score, float rectDimX, float rectDimY, float distBetweenRect, float barchartSizeX, float barchartSizeY) {
    float numberRectangles = ceil(score / 20);
    int limitRectangles = floor(barchartSizeY / (rectDimY + distBetweenRect));
    
    if (numberRectangles >= limitRectangles ) numberRectangles = limitRectangles;
    float rectPositionX = barchartSizeX ;
    float rectNextHeight =  barchartSizeY / 2 - rectDimY/2;
    
    for (int i = 0; i < numberRectangles; ++i) {
      fill (0,0,0);
      rect (rectPositionX,rectNextHeight,rectDimX, rectDimY);
      rectNextHeight -= (rectDimY  + distBetweenRect) ;
    }
  }
  
  /*void mouseDragged() {
    if(scrollBar.isMouseOver()) {
      println ("Mouse over ScrollBar");
      println(scrollBar.getPos());

    }
    else {
      if (first) {
        xMouse = mouseX;
        yMouse = mouseY;
        first = false;
      }
      else {
        if(!shiftPressed){
          if(yMouse < mouseY && (degrees(angleX) < 60)) angleX+=speed;
          else if(yMouse > mouseY && (degrees(angleX) > -60) )  angleX -= speed;
          yMouse = mouseY; 
          if(xMouse < mouseX && (degrees(angleZ) < 60)) angleZ+=speed;
          else if(xMouse > mouseX && (degrees(angleZ) > -60))  angleZ -= speed;
          xMouse = mouseX;
        }     
      }
    }
  }*/
  
  void mouseWheel(MouseEvent event) {
    float e = event.getCount();
    if (e < 0 && speed > 0.1) speed -= 0.001;
    else if (e > 0  && speed < 0.5)speed += 0.001;
  }
  
  void keyPressed(){
    if(key == CODED) {
      if (keyCode == SHIFT) {
         shiftPressed = true;
      }
    }
  }
  void keyReleased() {
    if(key == CODED) {
      if (keyCode == SHIFT) {
         shiftPressed = false;
      }
    }  
  }
  
  void mouseClicked() {
    int x = mouseX - width/2;
    int y = mouseY - height/2;
    if(scrollBar.isMouseOver()) {
            println ("Mouse over ScrollBar");
            println(scrollBar.getPos());
    }
    else {
      if(shiftPressed && mover.cylinders.overlapCheck(x, y)) {
        if((abs(x) < mover.halfBoard && abs(y) < mover.halfBoard) && (dist(x, y, mover.location.x, mover.location.z) > (mover.radius + mover.cylinders.cylinderBaseSize))){
          mover.cylinders.addCylinderAt(x, y);
        }
      }
    }
  }
  