ArrayList<PVector> hough(PImage edgeImg) {
  
    float discretizationStepsPhi = 0.015f;
    float discretizationStepsR = 1.5f;
    
    // dimensions of the accumulator
    int phiDim = (int) (Math.PI / discretizationStepsPhi);
    int rDim = (int) (((edgeImg.width + edgeImg.height) * 2 + 1) / discretizationStepsR);
    
    // our accumulator (with a 1 pix margin around)
    int[] accumulator = new int[(phiDim + 2) * (rDim + 2)];
    
    
    // pre-compute the sin and cos values
    float[] tabSin = new float[phiDim];
    float[] tabCos = new float[phiDim];
    float ang = 0;
    float inverseR = 1.f / discretizationStepsR;
    for (int accPhi = 0; accPhi < phiDim; ang += discretizationStepsPhi, accPhi++) {
      // we can also pre-multiply by (1/discretizationStepsR) since we need it in the Hough loop
      tabSin[accPhi] = (float) (Math.sin(ang) * inverseR);
      tabCos[accPhi] = (float) (Math.cos(ang) * inverseR);
    }
      
    
    // Fill the accumulator: on edge points (ie, white pixels of the edge
    // image), store all possible (r, phi) pairs describing lines going
    // through the point.
    for (int y = 0; y < edgeImg.height; y++) {
      for (int x = 0; x < edgeImg.width; x++) {
        // Are we on an edge?
        if (imgproc.brightness(edgeImg.pixels[y * edgeImg.width + x]) != 0) {
            
          // ...determine here all the lines (r, phi) passing through
          // pixel (x,y), convert (r,phi) to coordinates in the
          // accumulator, and increment accordingly the accumulator.
          // Be careful: r may be negative, so you may want to center onto
          // the accumulator with something like: r += (rDim - 1) / 2
          //int rMax = (int) ((edgeImg.width + edgeImg.height) * 2 + 1);
          
          for (int i = 0; i < phiDim; ++i ) {
             //float phi = i * discretizationStepsPhi;
             double r = x * tabCos[i] + y * tabSin[i];
             r += (rDim - 1)/2;
             accumulator[((i+1)*(rDim+2) + (int)(r+1))] += 1; 
          }
        }
      }
    }
  
  
    // Step 2
    
    //houghImg = createImage(rDim + 2, phiDim + 2, ALPHA);
    //for (int i = 0; i < accumulator.length; i++) {
    //  houghImg.pixels[i] = color(min(255, accumulator[i]));
    //}
    //// You may want to resize the accumulator to make it easier to see:
    //houghImg.resize(175, 240);
    //houghImg.updatePixels();
    
    ArrayList<Integer> bestCandidates = new ArrayList<Integer>();
    
    // size of the region we search for a local maximum
    int neighbourhood = 20;
    // only search around lines with more that this amount of votes
    // (to be adapted to your image)
    //int minVotes = 250;
    int minVotes = 120;
    for (int accR = 0; accR < rDim; accR++) {
      for (int accPhi = 0; accPhi < phiDim; accPhi++) {
        // compute current index in the accumulator
        int idx = (accPhi + 1) * (rDim + 2) + accR + 1;
        if (accumulator[idx] > minVotes) {
          boolean bestCandidate=true;
          // iterate over the neighbourhood
          for(int dPhi=-neighbourhood/2; dPhi < neighbourhood/2+1; dPhi++) {
            // check we are not outside the image
            if( accPhi+dPhi < 0 || accPhi+dPhi >= phiDim) continue;
              for(int dR=-neighbourhood/2; dR < neighbourhood/2 +1; dR++) {
                  // check we are not outside the image
                  if(accR+dR < 0 || accR+dR >= rDim) continue;
                  int neighbourIdx = (accPhi + dPhi + 1) * (rDim + 2) + accR + dR + 1;
                  if(accumulator[idx] < accumulator[neighbourIdx]) {
                      // the current idx is not a local maximum!
                      bestCandidate=false;
                      break;
                  }
               }
             if(!bestCandidate) break;
          }
          if(bestCandidate) {
            // the current idx *is* a local maximum
           bestCandidates.add(idx);
          }
        }
      }
    }
      
  
    Collections.sort(bestCandidates, new HoughComparator(accumulator));
    int nLines = 4;
    //int nLines = bestCandidates.size();
    ArrayList<PVector> lines = new ArrayList<PVector>();
    for (int i = 0; i < nLines; ++i) {
      if (i < bestCandidates.size()) {
      int idx = bestCandidates.get(i);
      // first, compute back the (r, phi) polar coordinates:
        int accPhi = (int) (idx / (rDim + 2)) - 1;
        int accR = idx - (accPhi + 1) * (rDim + 2) - 1;
        float r = (accR - (rDim - 1) * 0.5f) * discretizationStepsR;
        float phi = accPhi * discretizationStepsPhi;
        lines.add(new PVector(r,phi));
        
        // Cartesian equation of a line: y = ax + b
        // in polar, y = (-cos(phi)/sin(phi))x + (r/sin(phi))
        // => y = 0 : x = r / cos(phi)
        // => x = 0 : y = r / sin(phi)
        // compute the intersection of this line with the 4 borders of
        // the image
        int x0 = 0;
        int y0 = (int) (r / sin(phi));
        int x1 = (int) (r / cos(phi));
        int y1 = 0;
        int x2 = edgeImg.width;
        int y2 = (int) (-cos(phi) / sin(phi) * x2 + r / sin(phi));
        int y3 = edgeImg.width;
        int x3 = (int) (-(y3 - r / sin(phi)) * (sin(phi) / cos(phi)));
        // Finally, plot the lines
        imgproc.stroke(204,102,0);
        if (y0 > 0) {
          if (x1 > 0)
            imgproc.line(x0, y0, x1, y1);
          else if (y2 > 0)
            imgproc.line(x0, y0, x2, y2);
          else
            imgproc.line(x0, y0, x3, y3);
        }
        else {
          if (x1 > 0) {
            if (y2 > 0)
              imgproc.line(x1, y1, x2, y2);
            else
              imgproc.line(x1, y1, x3, y3);
          }
          else
            imgproc.line(x2, y2, x3, y3);
        }
      }
    }
      return lines;
  }