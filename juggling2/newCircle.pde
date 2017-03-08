class newCircle extends FCircle{
  int deathCount;
  
  newCircle(float size) {
    super(size);
    deathCount = 0;
    setPosition(width*0.7, 0);
    setDensity(10);
  }
  
  public void update(){
    if (getY() >= height-35){
      deathCount++;
    }
    if(deathCount>0){
       setVelocity(0,0); 
    }
  }
  
}