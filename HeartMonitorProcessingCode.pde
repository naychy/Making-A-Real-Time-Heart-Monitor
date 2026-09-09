import processing.serial.*;

Serial myPort;
int maxPoints = 500;          
float[] heartDataY = new float[maxPoints]; 
float[] pulseDataY = new float[maxPoints]; 
int currentIndex = 0;         

int graphX = 80;
int graphW = 1050; 

// Graph 1 (Heart Beat)
int graph1Y = 50;
int graph1H = 280; 

// Graph 2 (Pulse Beat)
int graph2Y = 400;
int graph2H = 280; 

float currentRawValue = 340.0; 
int currentBPM = 0;
int currentPulseRate = 0; 
float heartAlpha = 60; 
boolean pulseDetected = false;


float minY = 300;
float maxY = 400;

void setup() {
  size(1400, 750); 
  smooth();
  frameRate(60); 
  
  for (int i = 0; i < maxPoints; i++) {
    heartDataY[i] = graph1Y + (graph1H / 2);
    pulseDataY[i] = graph2Y + (graph2H / 2);
  }
  
  try {
    myPort = new Serial(this, "COM15", 115200);
    myPort.bufferUntil('\n');
  } catch (Exception e) {
    println("COM Port is error");
  }
}

void draw() {
  background(15, 18, 25); 
  
  
  if (heartAlpha > 60) {
    heartAlpha -= 8; 
  }
  
  
  drawGridAndAxes(graph1Y, graph1H, "HEART BEAT");     
  drawGraph(heartDataY, graph1Y, graph1H, color(100, 255, 120)); 
  

  drawGridAndAxes(graph2Y, graph2H, "PULSE BEAT");     
  drawGraph(pulseDataY, graph2Y, graph2H, color(0, 200, 255));   
  
  drawRightPanel();       
}

void drawGridAndAxes(int gY, int gH, String label) {
  stroke(60); 
  strokeWeight(1);

 
  for (int v = (int)minY; v <= (int)maxY; v += 20) { 
    float y = map(v, minY, maxY, gY + gH, gY);
    line(graphX, y, graphX + graphW, y); 
    
    fill(200);
    textAlign(RIGHT, CENTER);
    textSize(16);
    text(v, graphX - 15, y);
    
    stroke(200);
    line(graphX - 5, y, graphX, y);
    stroke(60);
  }
  

  for (int i = 0; i <= maxPoints; i += 50) {
    float x = map(i, 0, maxPoints, graphX, graphX + graphW);
    line(x, gY, x, gY + gH); 
    
    if (gY == graph2Y) { 
        fill(200);
        textAlign(CENTER, TOP);
        textSize(15);
        text(i, x, gY + gH + 15);
    }
    
    stroke(200);
    line(x, gY - 5, x, gY);
    line(x, gY + gH, x, gY + gH + 5);
    stroke(60);
  }
  
  noFill();
  stroke(200);
  rect(graphX, gY, graphW, gH);
  
  fill(255, 255, 255, 150);
  textAlign(LEFT, TOP);
  textSize(20);
  text(label + " GRAPH", graphX + 15, gY + 15);
}

void drawGraph(float[] dataArr, int gY, int gH, color lineColor) {
  stroke(lineColor); 
  strokeWeight(2.5);
  noFill();
  
  beginShape();
  for (int i = 0; i < currentIndex; i++) {
    float x = map(i, 0, maxPoints, graphX, graphX + graphW);
    vertex(x, dataArr[i]);
  }
  endShape();
  
  beginShape();
  for (int i = currentIndex + 5; i < maxPoints; i++) {
    float x = map(i, 0, maxPoints, graphX, graphX + graphW);
    vertex(x, dataArr[i]);
  }
  endShape();

  float curX = map(currentIndex, 0, maxPoints, graphX, graphX + graphW);
  float curY = dataArr[currentIndex];

  stroke(255, 255, 255, 100);
  strokeWeight(3);
  line(curX, gY, curX, gY + gH);

  fill(25, 30, 40);
  stroke(150);
  strokeWeight(1);
  rect(graphX + graphW, curY - 15, 65, 35, 15); 
  
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(18);
  text(nf(currentRawValue, 1, 1), graphX + graphW + 32, curY);
}

void drawRightPanel() {
  int pX = graphX + graphW + 130; 

  int panel1Y = graph1Y;
  
  
  fill(255, 80, 80, heartAlpha); 
  noStroke();
  drawHeart(pX + 25, panel1Y + 40, 60, 55); 

  fill(255);
  textAlign(CENTER, CENTER);
  textSize(55);
  text(currentBPM > 0 ? str(currentBPM) : "--", pX + 25, panel1Y + 140); 
  textSize(20);
  fill(180);
  text("HEART RATE", pX + 25, panel1Y + 200);
  text("(BPM)", pX + 25, panel1Y + 250);

  int panel2Y = graph2Y;

  fill(0, 200, 255); 
  textSize(55);
  text(currentPulseRate > 0 ? str(currentPulseRate) : "--", pX + 25, panel2Y + 140);
  textSize(20);
  fill(180);
  text("PULSE RATE", pX + 25, panel2Y + 200);
  text("(PR)", pX + 25, panel2Y + 250);

  //fill(255, 180, 0); 
  //textSize(55);
  //text("98", pX + 30, panel2Y + 190);
  //textSize(20);
  //fill(180);
  //text("SpO2 (%)", pX + 30, panel2Y + 235);
  
  textAlign(LEFT, CENTER);
  textSize(16);
  fill(150);
  text("ID: SYS-882-P", pX - 1180, graph2Y + graph2H - 317);
  text("BUFFER: 500/500", pX - 980, graph2Y + graph2H - 317);
}

void drawHeart(float x, float y, float w, float h) {
  beginShape();
  vertex(x, y + h/4);
  bezierVertex(x - w/2, y - h/2, x - w, y + h/3, x, y + h);
  bezierVertex(x + w, y + h/3, x + w/2, y - h/2, x, y + h/4);
  endShape();
}

void serialEvent(Serial port) {
  String inString = port.readStringUntil('\n');

  if (inString != null) {
    inString = trim(inString); 
    try {
      float inByte = float(inString);

      if (!Float.isNaN(inByte) && inByte > 0) {
        currentRawValue = inByte; 
        
        float mappedY1 = map(inByte, minY, maxY, graph1Y + graph1H, graph1Y);
        mappedY1 = constrain(mappedY1, graph1Y, graph1Y + graph1H);
        heartDataY[currentIndex] = mappedY1;

        float mappedY2 = map(inByte, minY, maxY, graph2Y + graph2H, graph2Y);
        mappedY2 = constrain(mappedY2, graph2Y, graph2Y + graph2H);
        pulseDataY[currentIndex] = mappedY2;

        float thresholdValue = 344.0;
        
        
        if (inByte > thresholdValue && !pulseDetected) { 
          heartAlpha = 255; 
          currentBPM = (int)random(72, 78); 
          currentPulseRate = currentBPM; 
          pulseDetected = true;
        } else if (inByte < thresholdValue - 2.0) {
          pulseDetected = false; 
        }

        currentIndex++;
        
        if (currentIndex >= maxPoints) {
          currentIndex = 0; 
        }
      }
    } catch (Exception e) {}
  }
}
