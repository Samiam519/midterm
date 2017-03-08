import processing.sound.*;
import fisica.*;
import de.voidplus.leapmotion.*;

LeapMotion leap;
float gravity;
float LHandSpeed, RHandSpeed;
PVector direction;
PVector position_finish;
PVector position_start;
float xDir, yDir;
float LHandX, LHandY;
float RHandX, RHandY;
boolean justDied;
int justDiedMusic;
int deathCounter;
int timeSinceLastNewBall;
int timeSinceLastLeftTouch;
int timeSinceLastRightTouch;
int score;
int highscore;
ArrayList<newCircle> circles = new ArrayList<newCircle>(); 
FCircle[] LeftHand = new FCircle[5];
FCircle[] RightHand = new FCircle[5];;
FWorld world;
SoundFile circus;
SoundFile powerDown;
SoundFile mario;

public void setup() {
  size(1200, 800);
  frameRate(120);
  leap = new LeapMotion(this).withGestures();
  ellipseMode(RADIUS);
  justDied = false;
  deathCounter = 0;
  timeSinceLastNewBall = 0;
  LHandX = 0;
  LHandY = 0;
  RHandX = 0;
  RHandY = 0;
  LHandSpeed = 0;
  RHandSpeed = 0;
  score = 0;
  highscore = 0;
  timeSinceLastLeftTouch = 0;
  timeSinceLastRightTouch = 0;
  justDiedMusic = 0;
  
  Fisica.init(this);
  world = new FWorld();
  world.setEdges();
  world.remove(world.top);
  newCircle c = new newCircle(30);
  circles.add(c);
  world.add(c);
  
  for(int i = 0; i < 5; i++){
     FCircle finger = new FCircle(30);
     LeftHand[i] = finger;
     world.add(finger);
  }
  for(int i = 0; i < 5; i++){
     FCircle finger = new FCircle(30);
     RightHand[i] = finger;
     world.add(finger);
  }
  
  circus = new SoundFile(this, "8bitcircus2.wav");
  circus.loop();
  powerDown = new SoundFile(this, "powerdown.wav");
  mario = new SoundFile(this, "mario.mp3");
}

public void draw() {
  world.step();
  world.draw();
  
  timeSinceLastNewBall++;
  timeSinceLastLeftTouch++;
  timeSinceLastRightTouch++;
     if (justDied) {
        background(255, 0, 0);
        deathCounter++;
        circus.amp(0.0);
        //powerDown.play();
        if(justDiedMusic == 1){
          mario.play();
          justDiedMusic = 0;
        }
        //mario.play();
        if(score > highscore){
           highscore = score; 
        }
        score = 0;
        }
    if (deathCounter >= 245){
        circus.amp(1.0);
        justDied = false;
        deathCounter = 0;
        }
    if(!justDied){
        background(0);
        }

  noStroke();
  fill(255);
  textSize(30);
  text("score: " + score, 10, 30);
  text("highscore: " + highscore, 10, 60);
  
  for (newCircle ball : circles) { 
      ellipse(ball.getX(), ball.getY(), ball.getSize(), ball.getSize());
      ball.update();
      //check death
      if(ball.deathCount == 1){
         justDied = true;
         justDiedMusic++;
      }
  }
  
  //update hand position each frame to compare on the next frame
  for(Hand hand : leap.getHands()){
     if(hand.isRight()){
       if(RHandX > 0){
          RHandSpeed = sqrt(sq(hand.getPosition().x - RHandX) + sq(hand.getPosition().y - RHandY));
          //println("right hand speed: " + RHandSpeed);
          for(Finger finger : hand.getFingers()){
             PVector fingerPos = finger.getPosition();
             RightHand[finger.getType()].setPosition(fingerPos.x, fingerPos.y);
             fill(0,255,255);
             ellipse(fingerPos.x, fingerPos.y, 10, 10);
             //FCircle fingerTip = new FCircle(10);
             //fingerTip.setPosition(fingerPos.x, fingerPos.y);
             //fingerTip.setDensity(0);
             //world.add(fingerTip);
             //ellipse(fingerTip.getX(), fingerTip.getY(), fingerTip.getSize(), fingerTip.getSize());
             //make fingers interact with ball
             for(newCircle ball : circles){
                 //if fingers touched ball
                 if ((sq(fingerPos.x - ball.getX()) + sq(fingerPos.y - ball.getY())) < sq(ball.getSize()) && ball.deathCount == 0) { 
                    if (RHandSpeed > 10) { //fingers are moving significantly
                        ball.addImpulse(abs(hand.getPosition().x - RHandX)*-200, abs(hand.getPosition().y - RHandY)*-350);
                        //ball.addImpulse(-2000, -3000);
                        println(abs(hand.getPosition().x - RHandX) + " " + abs(hand.getPosition().y - RHandY));
                        println("right hand impulse added");
                        //check for score
                        if(timeSinceLastRightTouch > 180){
                          score++;
                          timeSinceLastRightTouch = 0;
                        }
                    } else {
                      //ball.setPosition(fingerPos.x, fingerPos.y);
                    }
                 }
             }
           }
         }
         RHandX = hand.getPosition().x;
         RHandY = hand.getPosition().y; 
      }else if(hand.isLeft()){
          if(LHandX >0){
             LHandSpeed = sqrt(sq(hand.getPosition().x - LHandX) + sq(hand.getPosition().y - LHandY));
             //println("left hand speed:   " + LHandSpeed);
             for(Finger finger : hand.getFingers()){
                 PVector fingerPos = finger.getPosition();
                 LeftHand[finger.getType()].setPosition(fingerPos.x, fingerPos.y);
                 fill(0,255,255);
                 ellipse(fingerPos.x, fingerPos.y, 10, 10);
                 //make fingers interact with ball
                 for(newCircle ball : circles){
                    //if fingers touched ball
                    if ((sq(fingerPos.x - ball.getX()) + sq(fingerPos.y - ball.getY())) < sq(ball.getSize()) && ball.deathCount == 0) { 
                       if (LHandSpeed > 10) { //fingers are moving significantly
                           //ball.addImpulse(2000,-3000);
                           ball.addImpulse(abs(hand.getPosition().x - LHandX)*200, abs(hand.getPosition().y - LHandY)*-350);
                           println("left hand impulse added");
                           //check for score
                        if(timeSinceLastLeftTouch > 180){
                          score++;
                          timeSinceLastLeftTouch = 0;
                        }
                       } else {
                         //ball.setPosition(fingerPos.x, fingerPos.y);
                       }
                    } 
                }
             }
          }
          LHandX = hand.getPosition().x;
          LHandY = hand.getPosition().y;
      }
   }
  
}

void leapOnCircleGesture(CircleGesture g, int state) {
  int     id               = g.getId();
  Finger  finger           = g.getFinger();
  PVector positionCenter   = g.getCenter();
  float   radius           = g.getRadius();
  float   progress         = g.getProgress();
  long    duration         = g.getDuration();
  float   durationSeconds  = g.getDurationInSeconds();
  int     direction        = g.getDirection();

  switch(state) {
  case 1: // Start
    break;
  case 2: // Update
    break;
  case 3: // Stop
    println("CircleGesture: " + id);
    if(timeSinceLastNewBall > 300){
      newCircle anothaOne;
      anothaOne = new newCircle(30);
      circles.add(anothaOne);
      world.add(anothaOne);
      timeSinceLastNewBall = 0;
    }
    break;
  }

  switch(direction) {
  case 0: // Anticlockwise/Left gesture
    break;
  case 1: // Clockwise/Right gesture
    break;
  }
}

void leapOnSwipeGesture(SwipeGesture g, int state) {
  int     id                  = g.getId();
  Finger  finger              = g.getFinger();
  position_finish             = g.getPosition();
  position_start              = g.getStartPosition();
  direction                   = g.getDirection();
  float   speedOfHand         = g.getSpeed();
  long    duration            = g.getDuration();
  float   duration_seconds    = g.getDurationInSeconds();

  switch(state) {
  case 1: // Start
    break;
  case 2: // Update
    break;
  case 3: // Stop
    //println("SwipeGesture: "+id);
    //println("speedHand " + speedOfHand);
    //println("direction " + direction);
    xDir = position_finish.x - position_start.x;
    yDir = position_finish.y - position_start.y;
    //println("x direction: " + xDir);
    break;
  }
}