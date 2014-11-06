//values setup to work with headphones

import ddf.minim.ugens.*;
import ddf.minim.analysis.*;
import ddf.minim.*;
import ddf.minim.signals.*;

Minim minim;
AudioInput in;
AudioOutput out;

Oscil fm;
InputOutputBind signal;

float buffer[];
float gain;
FFT fft;
float avg, strokeSize;
float scaleAmt, rotAmt, transZ;


void setup() {
  size(1920, 1080, P3D);
  minim = new Minim(this);
  gain = height;
  int bufferSize = 2048;

  in = minim.getLineIn(Minim.MONO, bufferSize);
 
  buffer = new float[in.bufferSize()];
  fft = new FFT(in.bufferSize(), in.sampleRate());
  println(in.bufferSize());
  
  
  out = minim.getLineOut(Minim.MONO, bufferSize);
  
  
  signal = new InputOutputBind(bufferSize);
  //add listener to gather incoming data
  in.addListener(signal);
  // adds the signal to the output
  out.addSignal(signal);
  /*
  
  Oscil wave = new Oscil( 200, 0.8, Waves.TRIANGLE );

  fm   = new Oscil( 10, 2, Waves.SINE );
  fm.offset.setLastValue( 200 );
  fm.patch( wave.frequency );
  wave.patch( out );
  */
  
}

void draw() {
  
 strokeWeight(20*(rotAmt%frameCount));

  pushMatrix();
  
  translate(0,-frameCount/10, -frameCount); //push back and up
  translate(width/2, 0);
  rotAmt += scaleAmt/gain;
  println(rotAmt %frameCount);
  rotateY((rotAmt%frameCount));
  
  translate(-width/2, 0);
  translate((width- (scaleAmt * width))/2, (height - (scaleAmt * height))/2);
  scale(scaleAmt);
  //background(0);
  noStroke();
  stroke(255, 100);
  float maxBuffer = 0;
  fill(0, 10);
  rect(0, 0, width+frameCount, height+frameCount);
  translate(0, height/2);
  //strokeWeight(5);

  for (int i = 0; i < in.bufferSize (); i++) {
    buffer[i] = in.mix.get(i); 
    if (buffer[i] > maxBuffer) {
      maxBuffer += buffer[i];
    }
  }
  
  strokeWeight(strokeSize);
  stroke(255,200);

  float avgDiff = 0;
  float lrgDiff = 0;
  for (int i = 0; i < in.bufferSize ()-1; i++) {
    float x1 = map(i, 0, in.bufferSize(), 0, width);
    float x2 = map(i+1, 0, in.bufferSize(), 0, width);

    avgDiff += (buffer[i]-(buffer[i+1]));
    line(x1, buffer[i] * gain*5, x2, buffer[i+1] * gain/5);
    //rect(x1, buffer[i] * gain, x1+10, buffer[i+1] * gain);
    //println(buffer[i] + " is buffer[i] and   " + buffer[i+1]);
    if (buffer[i] - (buffer[i+1]) > lrgDiff){
      lrgDiff = buffer[i] - buffer[i+1];
    }
    
 
    
  }
  //println(avgDiff * gain/20);
  avgDiff /= in.bufferSize();
  scaleAmt = map(abs(avgDiff), 0, lrgDiff, 0.2, 200);
  //scale(scaleAmt);
  popMatrix();
  
  
  
    fft.forward(in.mix);
  int many =5;
  for (int i = 0; i < fft.specSize ()-many; i+= many) {
    int xx = width/fft.specSize();
    stroke(255);
    //rect(i * xx, height, i * xx * 2, height - fft.getBand(i)*100);
    stroke(255, 0, 0);
    fill(255, 0, 0, 100);
    //line(i*xx, height, i*xx, height - fft.getBand(i)*100); 


    for (int h = i; h < i+many; h++) {
      avg += fft.getBand(h);
    }
    avg /= many;
    noStroke();

    float avgColor = (avg * gain) / height;
    avgColor = constrain(avgColor, 0, 1);
    //println(avgColor);
    fill(200 * avgColor, 10*avgColor, 10*avgColor, 50*avgColor);
    rect(i * xx, height, (i+many) * xx, height - (avg * (gain) * (width/384)));
    //println(i * xx + ", " + ((i + many) * xx));
    avg = 0;
  }

  strokeSize = abs(avgDiff * gain * 20);
  
}

void stop() {

  in.close();
  minim.stop();
  super.stop();
}
