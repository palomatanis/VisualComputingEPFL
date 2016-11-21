public void sobel(PImage img) {
    imgproc.temp.loadPixels();
    color black = color(0);
    color white = color(255);

    // clear the image
    
    for (int i = 0; i < img.width * img.height; i++) {
      imgproc.temp.pixels[i] = black;
    }
   
    float max = 0;
    float [] buffer = new float[img.width * img.height];
    float weight = 1.f;
    float [] sum_h = new float[img.width * img.height];
    float [] sum_v = new float[img.width * img.height];
    float sum;
    float count, N = 3;
    float [][] temp = {{ 0, 0, 0 },
                       { 0, 0, 0 },
                       { 0, 0, 0 }};
    float [][] hKernel = { { 0, 1, 0 },
                          { 0, 0, 0 },
                          { 0, -1, 0 } };
    float[][] vKernel = { { 0, 0, 0 },
                          { 1, 0, -1 },
                          { 0, 0, 0 } };
  
    for(int i = img.width; i < img.width * img.height - img.width; i++) {
      if((i % img.width != 0) && (i % img.width != img.width-1)){
        count = 0;
        temp[0][0] = imgproc.brightness(img.pixels[i -img.width -1]) * hKernel [0][0]; 
        temp[0][1] = imgproc.brightness(img.pixels[i -img.width]) * hKernel [0][1];
        temp[0][2] = imgproc.brightness(img.pixels[i -img.width +1]) * hKernel [0][2];
        temp[1][0] = imgproc.brightness(img.pixels[i - 1]) * hKernel [1][0];
        temp[1][1] = imgproc.brightness(img.pixels[i]) * hKernel [1][1];
        temp[1][2] = imgproc.brightness(img.pixels[i + 1]) * hKernel [1][2];
        temp[2][0] = imgproc.brightness(img.pixels[i + img.width -1]) * hKernel [2][0];
        temp[2][1] = imgproc.brightness(img.pixels[i + img.width]) * hKernel [2][1];
        temp[2][2] = imgproc.brightness(img.pixels[i + img.width +1]) * hKernel [2][2];
           
        for(int j = 0; j < N; j++){
          for (int k = 0; k < N; k++){
            count = count + temp[j][k];
          }
        }
        sum_h[i] = count;
        
        count = 0;
        temp[0][0] = imgproc.brightness(img.pixels[i -img.width -1]) * vKernel [0][0]; 
        temp[0][1] = imgproc.brightness(img.pixels[i -img.width]) * vKernel [0][1];
        temp[0][2] = imgproc.brightness(img.pixels[i -img.width +1]) * vKernel [0][2];
        temp[1][0] = imgproc.brightness(img.pixels[i - 1]) * vKernel [1][0];
        temp[1][1] = imgproc.brightness(img.pixels[i]) * vKernel [1][1];
        temp[1][2] = imgproc.brightness(img.pixels[i + 1]) * vKernel [1][2];
        temp[2][0] = imgproc.brightness(img.pixels[i + img.width -1]) * vKernel [2][0];
        temp[2][1] = imgproc.brightness(img.pixels[i + img.width]) * vKernel [2][1];
        temp[2][2] = imgproc.brightness(img.pixels[i + img.width +1]) * vKernel [2][2];
         
        for(int j = 0; j < N; j++){
          for (int k = 0; k < N; k++){
            count = count + temp[j][k];
          }
        }
        sum_v[i] = count;
        
        sum = sqrt(pow(sum_h[i], 2) + pow(sum_v[i], 2)) / (float)(weight);
        
        max = max(max, sum);
        
        buffer[i] = sum;
      }
    }
    
    for (int y = 2; y < img.height - 2; y++) { // Skip top and bottom edges
      for (int x = 2; x < img.width - 2; x++) { // Skip left and right
        if (buffer[y * img.width + x] > (max * 0.3f)) { // 30% of the max
          imgproc.temp.pixels[y * img.width + x] = white;
        }
        else {
          imgproc.temp.pixels[y * img.width + x] = black;
        }
      }
    }
    imgproc.temp.updatePixels();
  }