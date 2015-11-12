import controlP5.*;
import java.util.regex.*;
import java.util.Collections;

BufferedReader reader;
ArrayList <TagCircle> circles;
ArrayList <TagCircle> temp;
ArrayList <Slot> slots;
ArrayList <SlotAnimation> slotsA;
Graph graph;
color c;
int tagCount = 0;
int numUniqueTags = 0;
int selectedTag;
String lastPost;
boolean totalStyle;
boolean prevStyle = true;
boolean showGraph = false;
int max = 0;
int maxC = 0;
double scale = 1.0;
int lastSlot = 0;
int sliderValue = 0;
int currentHour = 0;
int currentHour1 = 0;
ControlP5 cp5;
CheckBox checkbox;
Button buttonTotal;
Button buttonTime;
Slider slider;

/*******************************
 * SETUP METHOD
 *******************************/
void setup (){  
  size (1500, 850);  
  lastPost = "hi";
  totalStyle = true;
  graph = new Graph();
  // initialize slots
  slots = new ArrayList<Slot> ();
  slots.add(new Slot(70,100,0));
  
  cp5 = new ControlP5(this);
  checkbox = cp5.addCheckBox("checkBox")
                .setPosition(10, 10)
                .setColorForeground(color(120))
                .setColorActive(color(255))
                .setColorLabel(color(20))
                .setSize(10, 10)
                .setItemsPerRow(16)
                .setSpacingColumn(80)
                .setSpacingRow(20)
                ;
  buttonTime = cp5.addButton("Time")
                .setValue(1)
                .setPosition(900,650)
                .setSize(50,20)
                .setId(1)
                ;
  buttonTotal = cp5.addButton("Total")
                .setValue(0)
                .setPosition(800,650)
                .setSize(50,20)
                .setId(0)
                ;
  slider = cp5.addSlider("slider",0,200,0,800,615,500,20)
                ;

  circles = new ArrayList<TagCircle> ();
  loadViz();
  background(20);
}
public void slider(int theValue) {
  sliderValue = theValue;
}

public void Time(int theValue) {
  totalStyle = false;
  //print("eTime");
}
public void Total(int theValue) {
  totalStyle = true;
  //print("Total");
}
void loadViz()
{
  int count = 0;
  max = 0;

  circles = new ArrayList<TagCircle> ();
  temp = new ArrayList<TagCircle> ();
  String line;
  String hour;
  String[] pieces;
  String[] tags;
  int pCount;
  int cCount;
  int x,y;
  String tag;
  x = 70;
  y = 170;
  tagCount = 0;
  reader = createReader ("StackOverflow.csv");
  try {
    line = reader.readLine();
  } 
  catch (IOException e) {
    e.printStackTrace();
    line = null;
  }
  
  for (int i = 0; i < 70000; i ++)
  {
    try {
      line = reader.readLine();
    } 
    catch (IOException e) {
      e.printStackTrace();
      line = null;
    }

    if (line == null)
    {
      noLoop();
    }
    else
    {
      pieces = split(line, ",");
      hour = pieces[2].substring(1,3);
      if(currentHour1 != Integer.parseInt(hour)){
        currentHour1 = Integer.parseInt(hour);
        currentHour++;
      }
      println(currentHour);
      pieces[5] = pieces[5].replace("\"","");
      if(pieces[3].length() > 2) // ignore ""
      {
        Pattern p = Pattern.compile("<(.*?)>");
        Matcher m = p.matcher(pieces[3]);
        
        while ( m.find() )
        {
          tag = m.group(1);
          TagCircle foo = new TagCircle(tag,0,0,0); 
          if (!temp.contains(foo)){
            foo.incComment(Integer.parseInt(pieces[5]));
            foo.incPost();
            foo.addPoint(currentHour);
            /*temp.get(temp.indexOf(new TagCircle(tag))).incPost();
          }
          else{*/           
            temp.add(foo);
            tagCount++;
            
            // add slot
            if (x < 500){
              slots.add(new Slot(x,y,tagCount));
              x+= 100;
            }
            else {
              slots.add(new Slot(x,y,tagCount));
              x = 70;
              y += 100;
            }
          lastSlot++;
          }
         else if (!lastPost.equals(pieces[0]))
         {
           int idx = temp.indexOf(new TagCircle(tag));
           temp.get(idx).addPoint(currentHour);
           temp.get(idx).incPost();
           temp.get(idx).incComment(Integer.parseInt(pieces[5]));
           lastPost = pieces[0];
         }
        }
      }
    }
  }
  Collections.sort(temp);
  for (int i = 0; i < 20; i++){ //only get top 20
    checkbox.addItem(temp.get(i).mTag, i);
  }
  slider.setMax(currentHour-1);
}

void controlEvent(ControlEvent theEvent) {
  if (theEvent.isFrom(checkbox)) {
    
  int count = 0;
  max = 0;
  print("got an event from "+checkbox.getName()+"\t\n");
  // checkbox uses arrayValue to store the state of 
  // individual checkbox-items. usage:
  println(checkbox.getArrayValue());
  circles = new ArrayList<TagCircle> ();
  //temp = new ArrayList<TagCircle> ();
  
  String line;
  String[] pieces;
  String[] tags;
  int pCount;
  int cCount;
  int tagCount = 0;
  
    for (int i=0;i<checkbox.getArrayValue().length;i++) {
      int n = (int)checkbox.getArrayValue()[i];
      print(n);

      if (n == 1){
        circles.add((TagCircle)temp.get(i));
        circles.get(count).setId(count);
        
        count++;
        if (temp.get(i).mPostCount > max)
          max = temp.get(i).mPostCount;
        if (temp.get(i).mCommentCount > max)
          max = temp.get(i).mCommentCount;
      }
    }
    for (int k = 0; k < count; k++){
      circles.get(k).fixRadius();
      circles.get(k).updateLoc();
      circles.get(k).setAnimatable();
    }    
  }
}

/*******************************
 * DRAW METHOD
 *******************************/
void draw (){
  background(20);
  noStroke();
  fill(220 ,220 , 220);
  rect (0, 0, 1500, 20.0/16*50);

  for (int i = 0; i < circles.size(); i++){
    circles.get(i).update();
    circles.get(i).display();
  }
  if(showGraph)
    graph.show();
}

void mousePressed(){
  for (int i = 0; i < circles.size(); i++){
    circles.get(i).pressed();
  }
}

void mouseReleased(){
  for (int i = 0; i < circles.size(); i++){
    circles.get(i).dragged = false;
  }
}

/*******************************
 * SLOT CLASS
 *******************************/
public class Slot{
  int mX,mY;
  int oldX,oldY;
  int mID;
  private boolean changing;
  
  public Slot (int x, int y, int id){
    mX = x;
    mY = y;
    oldX = mX;
    oldY = mY;
    mID = id;
    changing = false;
  }
  
  public void transitionSlot(int incX, int incY, int id){
    mID = id;
    mX += incX;
    mY += incY;
  }
  
  public void startMoving(){
    changing = true;
    for (int i = 0; i < circles.size(); i++){
      circles.get(i).fixRadius();
  }
  }
  
  public void stopMoving(){
    changing = false;
  }
  
  public boolean isMoving(){
    return changing;
  }
}

/*******************************
 * SLOTANIMATION CLASS
 *******************************/
public class SlotAnimation {
  int x;
  int y;
  int id;
  
  public SlotAnimation (int incX, int incY, int newId){
    x = incX;
    y = incY;
    id = newId;
  }
  
  public void setAnimation (int incX, int incY, int newId){
    x = incX;
    y = incY;
    id = newId;
  }
}

/*******************************
 * TOOLTIP CLASS
 *******************************/
public class Tooltip {
  int mX;
  int mY;
  String text;
  
  public Tooltip (String txt, int x, int y) {
    text = txt;
    mX = x;
    mY = y;
  }
  
  public void show () {
    fill (60,60,60);
    rect (mX, mY, text.length() * 5, 60);
    fill (255,255,255);
    textSize (12);
    text (text, mX + 5, mY + 15);
  }
}

/*******************************
 * TAGCIRCLE CLASS
 *******************************/
public class TagCircle implements Comparable {
  ArrayList <Point> history;
  boolean over, doneExpanding, doneExpandingC;
  boolean moved = false;
  boolean dragged = false;
  int mX, mY;
  int newX,newY;
  double cR;
  double mR;
  //Slot lastSlot;
  int animatingR;
  int animatingCR;
  int mPostCount, mCommentCount, mMaxPostCount;
  int mID;
  String mTag;
  int []colorRGB;
  Tooltip tt;
  
  public TagCircle (String tag)
  {
    mTag = tag;
  }
  
  public TagCircle (String tag, int postCount, int commentCount, int slotId) {
    history = new ArrayList<Point>();
    over = false;
    doneExpanding = false;
    doneExpandingC = false;
    mTag = tag;
    mCommentCount = commentCount;
    mPostCount = postCount;
    mID = slotId;
    mX = slots.get(mID).mX;
    mY = slots.get(mID).mY;
    colorRGB = new int [3];
    setColorFromTag();
    mR = 10*pow(mPostCount,0.5);
    cR = 10*pow(mCommentCount,0.5);
    animatingR = 0;
    for (int i = 0; i < 100; i++)
    {
      history.add(new Point(i));
    }
  }
  public void setId(int id) {
    mID = id;
  }
  public void display() {
    if (over)
      fill(200,200,200);
    else {
      c = color(colorRGB[0], colorRGB[1], colorRGB[2]);
      fill(c);
    }  
    ellipse(mX, mY, (int)animatingR, (int)animatingR);
    fill(60, 60, 60, 60);
    stroke(50);
    if(totalStyle)
    ellipse(mX, mY, (int)animatingCR, (int)animatingCR);
    fill(255,255,255);
    noStroke();
    textSize(20);
    text(mTag,mX, mY);
    //print(totalStyle);
    if (over){
      if(totalStyle)
        new Tooltip(mTag + "\n" + mPostCount + " posts\n" + mCommentCount + " comments", mX, mY).show();
      else
        new Tooltip(mTag + "\n" + history.get(sliderValue).count + " posts\n" + "@Hour: " +history.get(sliderValue).hour, mX, mY).show();
    }
  }
  void update() { // update circle radius if animating or change mouseover status
    // for post circle    
    if (totalStyle){
      if(prevStyle == false){
        prevStyle = true;
        setAnimatable();
        
      }
      mR = 200*pow(mPostCount,0.5)/pow(max,0.5);
      cR = 200*pow(mCommentCount,0.5)/pow(max,0.5);
    }
    else
    {
      if(prevStyle == true){
        prevStyle = false;
        animatingR = (int)(10*pow(history.get(history.indexOf(new Point(sliderValue))).count,0.5));
        //setAnimatable();
      }
      if(history.contains(new Point(sliderValue))){
        //print ("found");
        animatingR = int(10*pow(history.get(history.indexOf(new Point(sliderValue))).count,0.5));
        mR = animatingR;
        //cR = 10*pow(history.get(history.indexOf(new Point(sliderValue))).count,0.5);
      }
    }
    
    if(totalStyle){
    if (!doneExpanding && animatingR < mR){
      animatingR++;
    }
    else if (!doneExpanding && animatingR > mR){
      animatingR--;
    }
    else
      doneExpanding = true;
    
    // for post circle
    if (!doneExpandingC && animatingCR < cR){
      animatingCR++;
    }
    else if (!doneExpandingC && animatingCR > cR){
      animatingCR--;
    }
    else
      doneExpandingC = true;
    }
    if (dragged)
    {
      mX = mouseX;
      mY = mouseY;
    }
    
    // for comment circle
    if (moved){
      newX = slots.get(mID).mX;
      newY = slots.get(mID).mY;
      
      if(mX < newX)
        mX++;
      else if (mX > newX)
        mX--;
        
      if(mY < newY)
        mY++;
      else if (mY > newY)
        mY--;

      if (mX == newX && mY == newY)
       moved = false; 
    }
      
    if (overEvent()) {
      over = true;
    }
    else
      over = false;
  }
  @Override
  public int compareTo(Object object) {
      if (mPostCount > ((TagCircle)object).mPostCount)
        return -1;
      else if (mPostCount == ((TagCircle)object).mPostCount)
        return 0;
      else
        return 1;
  }
  @Override
  public boolean equals(Object object)
  {
      boolean sameSame = false;

      if (object != null && object instanceof TagCircle)
      {
          sameSame = mTag.equals(((TagCircle)object).mTag);
          //if(sameSame)
          //println(mTag + "Found");
      }
      return sameSame;
  }
  boolean overEvent() { // Checks if pointer is over circle
    float disX = mX - mouseX;
    float disY = mY - mouseY;
    if (sqrt(sq(disX) + sq(disY)) < mR/2 ){
      //print (mTag);
      return true;
    }
    else
      return false;
  }
  void pressed() { // if mouse button is pressed over circle
    if (over) {
      print (mTag);
      moved = false;
      dragged = true;
      selectedTag = mID;
      showGraph = true;
    }
  }
  public void fixRadius(){ // adjust circle radius based off of maximum post count
    cR = 150*pow(mCommentCount,0.5)/pow(max,0.5);
    mR = 150*pow(mPostCount,0.5)/pow(max,0.5);
  }
  public void incPost(){ // adjust circle radius based off of maximum post count
    mPostCount++;
  }
  public void incComment(int value){ // adjust circle radius based off of maximum post count
    mCommentCount+=value;
  }
  public void setAnimatable()
  {
    doneExpandingC = false;
    doneExpanding = false;
  }
  public void incComment(){ // adjust circle radius based off of maximum post count
    mCommentCount++;
  }
  public void updateLoc()
  {
    moved = true;
  }
  public void addPoint(int hour)
  {
    if(history.contains(new Point(hour))){
      history.get(history.indexOf(new Point(hour))).incCount();
    }
    else
      history.add(new Point(hour));
  }
  private void setColorFromTag(){ // calculate color based off of tag
    int r, g, b;
    int sum = 0;
    int i;
    int tLength = mTag.length();
    byte[] bytes = mTag.getBytes();
    int colorLength = (mTag.length() + 2)/3;
      
    if(tLength > 2){
      for (i = 0; i < colorLength; i++){
        sum += bytes[i];
        //print(sum +  " Sum R ");
      }
      r = sum%256;
      sum = 0;
      
      for (i=i; i < colorLength*2; i++){
        sum += bytes[i];
       // print(sum +  " Sum G");
      }
      g = sum%256;
      sum = 0;
      
      for (i=i; i < mTag.length(); i++){
        sum += bytes[i];
        //print(sum +  " Sum B \n");
      }
      b = sum%256;
    }
    else{
      r = bytes[0]%256;
      g = bytes[0]%128;
      b = bytes[0]%64;
    }
    colorRGB[0] = r;
    colorRGB[1] = g;
    colorRGB[2] = b;
  }
}

public class Point {
  int hour;
  int count;
  
  public Point (int currHour) {
    count = 0;
    hour = currHour;
  }
  
  public void incCount () {
    count++;
  }
  
  @Override
  public boolean equals(Object object)
  {
      boolean sameSame = false;
    
      if (object != null && object instanceof Point)
      {
          if (hour == ((Point)object).hour)
            return true;
      }
      return sameSame;
  }
}

/*******************************
 * GRAPH CLASS
 *******************************/
public class Graph {
  ArrayList<Point> tagPoints;
  String tag;
  float scale;
  public Graph () {
  }
  
  public void show () {
    fill (255,255,255);
    rect (800, 100, 600, 510);
    tagPoints = circles.get(selectedTag).history;
    tag = circles.get(selectedTag).mTag;
    fill(0);
    stroke(20);
    line (810,110,810,590);
    line (810,590,1390,590);
    line (810+scale*sliderValue,590,810+scale*sliderValue,110);
    stroke(5);
    textSize(20);
    text ("Posts per hour about " + tag, 820,120);
    textSize(10);
    text ("96", 1380,600);
    text ("58", 805,110);
    for (int i = 0; i < tagPoints.size()-1; i++)
    {
      scale = ((float)580)/currentHour;
      line(810 + scale*tagPoints.get(i).hour,590 - 10*tagPoints.get(i).count,810 + scale*tagPoints.get(i+1).hour,590 - 10*tagPoints.get(i+1).count);
      //println(tagPoints.get(i).count);
    }
    noStroke();
  }
}
