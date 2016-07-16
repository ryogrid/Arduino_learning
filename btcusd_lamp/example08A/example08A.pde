import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.StringTokenizer;
import java.io.InputStreamReader;
import java.net.URLConnection;
import java.net.URL;
// Example 08A: Arduino networked lamp
// parts of the code are inspired
// by a blog post by Tod E. Kurt (todbot.com)
//
// Copy and paste this example into an empty Processing sketch

import processing.serial.*;

String feed = "http://api.coindesk.com/v1/bpi/currentprice.json";

int interval = 60;  // retrieve feed every 60 seconds;
int lastTime;       // the last time we fetched the content

double price = 0;
double old_price = 0;
int love    = 0;
int peace   = 0;
int arduino = 0;

int light = 0;  // light level measured by the lamp

Serial port;
color c;
String cs;

String buffer = ""; // Accumulates characters coming from Arduino

PFont font;

void setup() {
  size(640,480);
  frameRate(10);    // we don't need fast updates

  font = loadFont("Meiryo-32.vlw");  
  fill(255);  
  textFont(font, 32);
  // IMPORTANT NOTE:
  // The first serial port retrieved by Serial.list()
  // should be your Arduino. If not, uncomment the next
  // line by deleting the // before it, and re-run the
  // sketch to see a list of serial ports. Then, change
  // the 0 in between [ and ] to the number of the port
  // that your Arduino is connected to.
  println(Serial.list());
  String arduinoPort = Serial.list()[1];
  port = new Serial(this, arduinoPort, 9600); // connect to Arduino

  lastTime = 0;
  fetchData();
}

void draw() {
  background( c );
  int n = (interval - ((millis()-lastTime)/1000));

  // Build a colour based on the 3 values
  c = color(peace, love, arduino);
  cs = "#" + hex(c,6); // Prepare a string to be sent to Arduino

  text("Arduino Networked Lamp", 10,40);
  text("Reading feed:", 10, 100);
  text(feed, 10, 140);

  text("price ",10,240);
  text(" " + String.valueOf(price), 130, 240);
  rect(200,212, love, 28);

  if (n <= 0) {
    fetchData();
    lastTime = millis();
  }

  if(old_price < price){
    port.write(1); // send data to Arduino
  }else{
    port.write(2);
}
//  port.write("#FFFFFF");

  if (port.available() > 0) { // check if there is data waiting
    int inByte = port.read(); // read one byte
    if (inByte != 10) { // if byte is not newline
      buffer = buffer + char(inByte); // just add it to the buffer
    }
    else {

      // newline reached, let's process the data
      if (buffer.length() > 1) { // make sure there is enough data

        // chop off the last character, it's a carriage return
        // (a carriage return is the character at the end of a
        // line of text)
        buffer = buffer.substring(0,buffer.length() -1);
 
        // turn the buffer from string into an integer number
        light = int(buffer);

        // clean the buffer for the next read cycle
        buffer = "";

        // We're likely falling behind in taking readings
        // from Arduino. So let's clear the backlog of
        // incoming sensor readings so the next reading is
        // up-to-date.
        port.clear(); 
      }
    } 
  }

}

void fetchData() {
  // we use these strings to parse the feed
  String data; 
  String chunk;

  // zero the counters
  love    = 0;
  peace   = 0;
  arduino = 0;
  try {
    URL url = new URL(feed);  // An object to represent the URL
    // prepare a connection   
    URLConnection conn = url.openConnection(); 
    conn.connect(); // now connect to the Website

    // this is a bit of virtual plumbing as we connect
    // the data coming from the connection to a buffered
    // reader that reads the data one line at a time.
    BufferedReader in = new
      BufferedReader(new InputStreamReader(conn.getInputStream()));

    // read each line from the feed
    while ((data = in.readLine()) != null) {

      //StringTokenizer st =
      //  new StringTokenizer(data,"\"<>.[]: ");// break it down
      //while (st.hasMoreTokens()) {
      //  // each chunk of data is made lowercase
      //  chunk= st.nextToken().toLowerCase() ;

        
      //  if (chunk.indexOf("okcoin") >= 0 ) // found "love"?
      //    price = Double.parseDouble(st.nextToken());
      //    price = Double.parseDouble(st.nextToken());
      //    price = Double.parseDouble(st.nextToken());
      //    price = Double.parseDouble(st.nextToken());
      //    old_price = price;  

      //    return;
      //}
      
      String regex = "rate\":\"(.+?)\"";
      Pattern p = Pattern.compile(regex);

      Matcher m = p.matcher(data);
      if (m.find()){
        String matchstr = m.group(1);
        old_price = price;
        price = Double.parseDouble(matchstr);
        return;
      }      
    }

    // Set 64 to be the maximum number of references we care about.
    if (peace > 64)   peace = 64;
    if (love > 64)    love = 64;
    if (arduino > 64) arduino = 64;

    peace = peace * 4;     // multiply by 4 so that the max is 255,
    love = love * 4;       // which comes in handy when building a
    arduino = arduino * 4; // colour that is made of 4 bytes (ARGB)
  } 
  catch (Exception ex) { // If there was an error, stop the sketch
    ex.printStackTrace();
    System.out.println("ERROR: "+ex.getMessage());
  }

}