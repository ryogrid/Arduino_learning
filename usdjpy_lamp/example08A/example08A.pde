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

String feed = "https://api-fxpractice.oanda.com/v1/prices?instruments=USD_JPY";

int interval = 1;  // retrieve feed every 60 seconds;
int lastTime;       // the last time we fetched the content

double price = 0;
double old_price = 0;

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

  text("Arduino Networked Lamp", 10,40);
  text("Reading feed:", 10, 100);
  text(feed, 10, 140);

  text("Next update in "+ n + " seconds",10,450);
  
  text("price ",10,240);
  text(" " + String.valueOf(price), 130, 240);

  if (n <= 0) {
    fetchData();
    lastTime = millis();
    
    if(old_price < price){
      port.write(1); // send data to Arduino
    }else if(old_price==price){
      port.write(0);
    }else{
      port.write(2);
    }
  }

}

void fetchData() {
  // we use these strings to parse the feed
  String data; 

  try {
    URL url = new URL(feed);  // An object to represent the URL
    // prepare a connection   
    URLConnection conn = url.openConnection(); 
    conn.setRequestProperty("Authorization","Bearer <YOUR OANDA DEMO ACCOUNT TOKEN>");
    conn.connect(); // now connect to the Website

    // this is a bit of virtual plumbing as we connect
    // the data coming from the connection to a buffered
    // reader that reads the data one line at a time.
    BufferedReader in = new
      BufferedReader(new InputStreamReader(conn.getInputStream()));

    // read each line from the feed
    while ((data = in.readLine()) != null) {      
      String regex = "bid\" : (.+?),";
      Pattern p = Pattern.compile(regex);

      Matcher m = p.matcher(data);
      if (m.find()){
        String matchstr = m.group(1);
        old_price = price;
        price = Double.parseDouble(matchstr);
        return;
      }      
    }
  } 
  catch (Exception ex) { // If there was an error, stop the sketch
    ex.printStackTrace();
    System.out.println("ERROR: "+ex.getMessage());
  }

}