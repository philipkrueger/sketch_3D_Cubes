import codeanticode.syphon.*;


SyphonServer server;

int grid, depth, reso, sizeX, sizeY, boxSize = 20, alpha, feedback = 255;
float inc = 0.01, wireFrame = 1.0;

PGraphics[] views = new PGraphics[6];                // Array of canvases to draw 6 images of the cubemap 
PVector[] camDirection = new PVector[6];            // Vectorarray to set the directions of the cams
PVector[] camUp = new PVector[6];                  // Vectorarray to align the cams

void setup(){
 size (1200, 900, P2D);                            // 2D Renderer for the final composition
 surface.setResizable(true);                      // window size is adjustable
 server = new SyphonServer(this, getClass().getSimpleName()); //  setup a syphon server for output
 grid = 5;
 newScale();                   // function to setup things at setup but also after resizing the window
 
 
}

void draw(){ 
  
  if ((width != sizeX) || (height != sizeY)){          // check if the window is resized and the newScale() function has to run again        
    newScale();
  }
 
 boxSize = int(map(mouseX, 0, width, 0, height/grid));   // interaction
 alpha = int(map(mouseY, 0, height, 0, 255));
 

 for (int i = 0; i < 6; i++){    // loop to write in 6 seperate canvases -> the 6 views of the cubemap
  
  views[i].beginDraw();          // PGraphics start
  
  views[i].pushMatrix();
  views[i].translate(width/2,  height/2, 0);
  views[i].fill(150,feedback);                      // color for the background 
  views[i].noStroke();
  views[i].box(10*reso);                           // box to draw a blank background in all directions
  views[i].popMatrix();   
  views[i].lights();
  
  // cameras with individual vectors for direction and aligning
  views[i].camera(width/2, height/2, 0, camDirection[i].x, camDirection[i].y, camDirection[i].z, camUp[i].x, camUp[i].y, camUp[i].z); 
  views[i].perspective(PI/2, 1, 10, 2*depth); // Set the cams to 90° field of view (PI/2) and the imageratio of 1:1
 
   for (int x = 0; x < grid; x++){                // creating a grid for the boxes
     for (int y = 0; y < grid; y++){
       for (int z = 0; z < grid; z++){
         views[i].pushMatrix();
         views[i].translate(width/2, 0, 0);
         views[i].rotateY(inc);                        //rotate the whole scene 
         views[i].rotateZ(inc);
         views[i].translate(-width/2, 0, -depth/2);
         views[i].pushMatrix();
         views[i].translate(width/grid*x, height/grid*y, depth/grid*z);    // set individual locations for the boxes
         views[i].fill(255, 255* wireFrame);                               // box colors mono
         views[i].box(boxSize);                                            // draw the boxes
         views[i].fill(255/grid*x, 255/grid*y, 255/grid*z, alpha * wireFrame); // raibow colors for the boxes to fade/overlay
         views[i].stroke(0, 255 - 255*wireFrame);                            // wireframes of the boxes
         views[i].box(boxSize);                                               
         views[i].popMatrix();    
         views[i].popMatrix();
 }}} 
 
 views[i].endDraw();    // end of PCanvas
 }

 inc += 0.01;            // counter for the rotation
 
 // final composition of the cubemap:
 
  image(views[0],reso,reso);    //front
  image(views[3],2*reso,reso);  //right
  image(views[2],3*reso,reso);  //back
  image(views[1],0,reso);       //left
  image(views[4],reso,0);       //up
  image(views[5],reso,2*reso);  //down
  
  
  server.sendScreen(); //send final composition to syphon
}

// this is the function which is called in setup and every time the window is resized:

void newScale(){
  
  depth = height;              // depth of the space equals the window height
  reso = depth/3;              // width and height of each view of the cubemap
  
  for (int i = 0; i < 6; i++){
    views[i] = createGraphics(reso, reso, P3D);       // create 6 empty images for the cubemap
    camUp[i] = new PVector(0, 1, 0);                 // All cams get the same Up vector to align   
  }
  camUp[4] = new PVector(0, 0, 1);                    // overwrites the Up vectors for looking up and down
  camUp[5] = new PVector(0, 0, -1);


// set targets for the cams to point them to their directions:

  camDirection[0] = new PVector(width/2, height/2, depth/2);       //front
  camDirection[1] = new PVector(width, height/2, 0);               //right
  camDirection[2] = new PVector(width/2, height/2, -depth/2);      //back
  camDirection[3] = new PVector(0, height/2, 0);                   //left
  camDirection[4] = new PVector(width/2, 0, 0);                    //up
  camDirection[5] = new PVector(width/2, height, 0);               //down 
  
  sizeX = width;            // remember actual size to check if the window is resized at the beginning of draw()
  sizeY = height;
}

void mousePressed(){  
  if (feedback == 10) {
    feedback = 255;
  } else {
    feedback = 10;
  }
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount()*0.001;
  wireFrame += e;
  if (wireFrame > 1){
    wireFrame = 1;
  }
   if (wireFrame < 0){
    wireFrame = 0;
  }
}
