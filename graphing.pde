import net.objecthunter.exp4j.Expression; //imports for parsing user input and evaluating functions
import net.objecthunter.exp4j.ExpressionBuilder;
import ddf.minim.*;  // Import the Minim library

Minim minim;
AudioPlayer player;
PFont font; // added font from data file

int currentScreen = 0; // start program at main menu

Expression expression;
String userInput = ""; // initialize user input to be empty
boolean enterPressed = false; //enter has not been pressed

//variables for moving text in main menu
float theta = 0;
float speed = 0.15;

//variables for animation in main menu
float offset = 0;
float wspeed = 1.5;
float freq = 0.1;
float amp = 30;
float unit = 50;
float factor = 0.65;
void scaleFactor(){
}

void setup() {
  size(1280, 720);
  minim = new Minim(this);
  player = minim.loadFile("music.mp3");
  player.setGain(-18);
  player.loop();
}

void draw() {
  //switching between screens
  if (currentScreen == 0) {
    mainMenu();
  } 
  else if (currentScreen == 1) {
    inputScreen();
  } 
  else if (currentScreen == 2) {
    graphScreen();
  }
}
float xScreen(float x){
  return  width/2 + x*50*factor;
}
float yScreen(float y){
  return height/2 - y*50*factor;
}
void drawAxes() {
  
  strokeWeight(1);
  stroke(0);
  line(xScreen(-10),yScreen(0),xScreen(10),yScreen(0)); //x-axis
  line(xScreen(0),yScreen(-10),xScreen(0),yScreen(10)); //y-axis

  //lines on axis
  for (int i = -10; i <= 10; i++) {
    line(xScreen(i), yScreen(0) - 5, xScreen(i), yScreen(0) + 5);    
    line(xScreen(0) - 5, yScreen(i), xScreen(0) + 5, yScreen(i));
  }
}

void keyPressed() {
  if(currentScreen != 1){
    return;
  }
  if (key == BACKSPACE && userInput.length() > 0) {
    userInput = userInput.substring(0, userInput.length() - 1);
  } else if (key != CODED && key != ENTER) {
    userInput += key;
  }
}

void keyReleased() {
  enterPressed = false;
}

float evaluateFunction(float x) {
  if(expression == null){
    userInput = "";
    return 0;
  }
  try{
    expression.setVariable("x", x);
    return (float) expression.evaluate();  // find f(x)
  }
  catch(Exception e){
    userInput = "";
    return 0;
  }
   
}

void graphFunction() {
  stroke(0);
  noFill();
  beginShape();

  for (float x = -10; x <= 10; x += 0.01) {
    float fx = evaluateFunction(x); 
    float forward = evaluateFunction(x+0.1);
    if(abs(fx-forward) > 100){
      vertex(xScreen(x), yScreen(fx));
      endShape();
      beginShape();
    }
    else{
      vertex(xScreen(x), yScreen(fx)); // add vertex to shape (line)
    }
  }

  endShape();  
}

void prepareGraph(String userInput) {
      if(userInput == ""){
        currentScreen = 1;
        return;
      }
      try{
      expression = new ExpressionBuilder(userInput)
        .variables("x")
        .build();
      }
      catch(UnknownFunctionOrVariableException e){
        currentScreen = 1;
    
      }
}

void mainMenu() { //fun area with visuals
  
  background(255);
    //create animated wave
  stroke(0);
  strokeWeight(2);
  beginShape();
  for(float xcoor=0;xcoor<width;xcoor++){
    float ycoor = 150 + height/4 +sin((xcoor+offset)*freq)*amp;
    vertex(xcoor,ycoor);
  }
  endShape();
  
  offset += wspeed;
  
  //creating grid lines with opacity
  stroke(80, 80, 80, 80);
  int gridSize = 16;
  strokeWeight(2.5);

  for (int i = 0; i < width; i += gridSize) {
    line(i, 0, i, height);
  }
  for (int i = 0; i < height; i += gridSize) {
    line(0, i, width, i);
  }
  
  
  
  //finish with background elements
  filter(BLUR,1.15);
  fill(0);
  
  //import font to use and add moving text;
  font = createFont("CascadiaCode.ttf",64);
  textFont(font);
  textSize(64);
  textAlign(CENTER, CENTER);
  float yPosition = 100 + sin(theta) * 18;
  text("Welcome to Graphit", width / 2, yPosition);
  theta += speed;
  textSize(32);
  text("( Click anywhere to start )",width/2,530);
  //check for instructions to change screens
  if (mousePressed) {
    currentScreen = 1;
  }
}

void inputScreen() { //screen where user inputs desired function to be graphed
  background(255);
  stroke(80, 80, 80, 80);
  int gridSize = 16;
  strokeWeight(2.5);

  for (int i = 0; i < width; i += gridSize) {
    line(i, 0, i, height);
  }
  for (int i = 0; i < height; i += gridSize) {
    line(0, i, width, i);
  }
  filter(BLUR,1.15);
  fill(0);
  textSize(36);
  textAlign(CENTER, CENTER);
  text("Please Enter a Valid Function f(x):", width / 2, 100);
  text(userInput, width / 2, 200); // display user input as they type
  textSize(24);
  text("( all values graphed from {-10≤x≤10} )",width/2,440);
  textSize(16);
  text("Press (Enter) to graph your function",width/6*5,height-100);
  text("Press (m) to return to Title Screen",width/6*5,height -50);

  if (keyPressed && (key == 'm' || key == 'M')) {
    currentScreen = 0;
    userInput = "";
  }

  if (keyCode == ENTER && !enterPressed) {
    enterPressed = true;
    currentScreen = 2;
    prepareGraph(userInput); // prep graph before screen switch
  }
}

void graphScreen() {
  background(255);
  textAlign(CENTER, CENTER);
  drawAxes();
  graphFunction();
  if (expression != null) { //prevents error by making sure to only graph when there is a valid function to graph
    graphFunction();
    textSize(16);
    text("f(x) = " + userInput,width/2,18);
    text("Press (b) to graph another function",width/6*5,height-100);
    text("Press (m) to return to Title Screen",width/6*5,height -50);
  }

  if (keyPressed && (key == 'b' || key == 'B')) {
    currentScreen = 1;
    userInput = "";
  }
  if (keyPressed && (key == 'm' || key == 'M')) {
    currentScreen = 0;
    userInput = "";
  }
}
