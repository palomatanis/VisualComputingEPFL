void thresholding(PImage img) {
   imgproc.temp.loadPixels();
   color black = color(0, 0, 0);
   color white = color(255,255,255);
   //float hueMax = 140;
   //float hueMin = 80;
   //float brightnessMax = 240;
   //float brightnessMin = 0;
   //float saturationMax = 265;
   //float saturationMin = 100;  
   
   float hueMax = 138;
   float hueMin = 70;
   float brightnessMax = 235;
   float brightnessMin = 30;
   float saturationMax = 265;
   float saturationMin = 100;  

   for(int i = 0; i < img.width * img.height; i++) {
     // do something with the pixel img.pixels[i]
     int pixel = img.pixels[i];
      
     if (hue(pixel)>hueMin && hue(pixel) < hueMax  && imgproc.brightness(pixel) < brightnessMax && imgproc.brightness(pixel) > brightnessMin
         && imgproc.saturation(pixel) > saturationMin && imgproc.saturation(pixel) < saturationMax){
         imgproc.temp.pixels[i] = white;
         }
     else imgproc.temp.pixels[i] =  black;
   }
   imgproc.temp.updatePixels();
}