  /*void blur (PImage img) {
    imgproc.result.loadPixels();
    float[][] kernel = { { 9, 12, 9 },
                        {12, 15, 12 },
                        { 9, 12, 9 }};
                 
    float [][] temp =  {{ 0, 0, 0 },
                       { 0, 0, 0 },
                       { 0, 0, 0 }};
                       
    //PImage result = createImage(img.width, img.height, ALPHA);
    float count, N = 3;

      
    float weight = 100.f;
    
    for(int i = img.width; i < img.width * img.height - img.width; i++) {
      
      if((i % img.width != 0) && (i % img.width != img.width-1)){
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
           
        for(int j = 0; j < N; j++){
          for (int k = 0; k < N; k++){
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
 
 
 
int getIntFromColor(float Red, float Green, float Blue){
    int R = Math.round(255 * Red);
    int G = Math.round(255 * Green);
    int B = Math.round(255 * Blue);

    R = (R << 16) & 0x00FF0000;
    G = (G << 8) & 0x0000FF00;
    B = B & 0x000000FF;

    return 0xFF000000 | R | G | B;
}*/