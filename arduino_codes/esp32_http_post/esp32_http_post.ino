
/*

Board Settings
Board: AI Thinker ESP32-CAM
CPU Frequency: 240 MHz (WiFi/BT)
Flash Frequency: 80 MHz
Flash Mode: QIO
Partition Scheme: Huge App (3MB No OTA/1MB SPIFFS)

*/

#include <Arduino.h>
#include <WiFi.h>
#include "soc/soc.h"
#include "soc/rtc_cntl_reg.h"
#include "esp_camera.h"

WiFiClient client;

// WiFi connection credentials (SSID and password)
const char* ssid = "";
const char* password = "";

// Server information
String serverName = "";   // Server IP address
String serverPath = "/php-scripts/imgupload.php";     
const int serverPort = 80;

// CAMERA_MODEL_AI_THINKER
#define PWDN_GPIO_NUM     32
#define RESET_GPIO_NUM    -1
#define XCLK_GPIO_NUM      0
#define SIOD_GPIO_NUM     26
#define SIOC_GPIO_NUM     27

#define Y9_GPIO_NUM       35
#define Y8_GPIO_NUM       34
#define Y7_GPIO_NUM       39
#define Y6_GPIO_NUM       36
#define Y5_GPIO_NUM       21
#define Y4_GPIO_NUM       19
#define Y3_GPIO_NUM       18
#define Y2_GPIO_NUM        5
#define VSYNC_GPIO_NUM    25
#define HREF_GPIO_NUM     23
#define PCLK_GPIO_NUM     22

// Enable LED FLASH setting
#define CONFIG_LED_ILLUMINATOR_ENABLED 1

// LED FLASH setup
#if CONFIG_LED_ILLUMINATOR_ENABLED

#define LED_GPIO_NUM                4
#define LED_LEDC_CHANNEL            2
#define CONFIG_LED_MAX_INTENSITY  255 
#define LED_INTENSITY             127

void enable_led(bool en, int led_duty);

#endif

#define uS_TO_S_FACTOR 1000000ULL  /* Conversion factor for micro seconds to seconds */
#define TIME_TO_SLEEP  120        /* Time ESP32 will go to sleep (in seconds) */

void setSensor();
void setupLedFlash();
void connectWifi();
void print_wakeup_reason();
camera_fb_t * takePhoto();
String sendPhoto(camera_fb_t * fb);


void setup() {

  WRITE_PERI_REG(RTC_CNTL_BROWN_OUT_REG, 0); 
  delay(1000);
  Serial.begin(115200);
  print_wakeup_reason();

  // Camera configurations
  camera_config_t config;
  config.ledc_channel = LEDC_CHANNEL_0;
  config.ledc_timer = LEDC_TIMER_0;
  config.pin_d0 = Y2_GPIO_NUM;
  config.pin_d1 = Y3_GPIO_NUM;
  config.pin_d2 = Y4_GPIO_NUM;
  config.pin_d3 = Y5_GPIO_NUM;
  config.pin_d4 = Y6_GPIO_NUM;
  config.pin_d5 = Y7_GPIO_NUM;
  config.pin_d6 = Y8_GPIO_NUM;
  config.pin_d7 = Y9_GPIO_NUM;
  config.pin_xclk = XCLK_GPIO_NUM;
  config.pin_pclk = PCLK_GPIO_NUM;
  config.pin_vsync = VSYNC_GPIO_NUM;
  config.pin_href = HREF_GPIO_NUM;
  config.pin_sscb_sda = SIOD_GPIO_NUM;
  config.pin_sscb_scl = SIOC_GPIO_NUM;
  config.pin_pwdn = PWDN_GPIO_NUM;
  config.pin_reset = RESET_GPIO_NUM;
  config.xclk_freq_hz = 20000000;

  config.frame_size = FRAMESIZE_UXGA;
  config.pixel_format = PIXFORMAT_JPEG;
  config.jpeg_quality = 4;  //0-63 lower number means higher quality
  config.fb_location = CAMERA_FB_IN_PSRAM;
  config.fb_count = 2;
  config.grab_mode = CAMERA_GRAB_LATEST;

  // Check for PSRAM
  // init with high specs to pre-allocate larger buffers
  if(!psramFound()){
    Serial.println("PSRAM is not found, restarting");
    Serial.flush();
    ESP.restart();
  }

  // Initialize the camera
  esp_err_t err = esp_camera_init(&config);
  delay(1000);

  if (err != ESP_OK) {
    Serial.printf("Camera init failed with error 0x%x\n", err);
    Serial.flush();
    ESP.restart();
  }

  setSensor();
  setupLedFlash();

  // Capture a photo
  camera_fb_t * fb = takePhoto();
  if(!fb) {
    esp_camera_fb_return(fb);
    esp_camera_deinit();
    delay(1000);
    ESP.restart();
  }

  // Connect to WiFi and send the photo
  connectWifi();
  sendPhoto(fb);
  
  // Disconnect WiFi and clean up
  WiFi.disconnect();
  esp_camera_fb_return(fb);
  esp_camera_deinit();

  // Configure for deep sleep
  esp_sleep_enable_timer_wakeup(TIME_TO_SLEEP * uS_TO_S_FACTOR);
  Serial.println("Setup ESP32 to sleep for every " + String(TIME_TO_SLEEP) + " Seconds");
  Serial.println("Going to sleep now");
  Serial.flush(); 
  esp_deep_sleep_start();

}

void loop() {}

inline void setSensor(){

  sensor_t * s = esp_camera_sensor_get();
  s->set_brightness(s, 0);     // -2 to 2
  s->set_contrast(s, 0);       // -2 to 2
  s->set_saturation(s, 0);     // -2 to 2
  s->set_special_effect(s, 0); // 0 to 6 (0 - No Effect, 1 - Negative, 2 - Grayscale, 3 - Red Tint, 4 - Green Tint, 5 - Blue Tint, 6 - Sepia)
  s->set_whitebal(s, 1);       // 0 = disable , 1 = enable
  s->set_awb_gain(s, 1);       // 0 = disable , 1 = enable
  s->set_wb_mode(s, 0);        // 0 to 4 - if awb_gain enabled (0 - Auto, 1 - Sunny, 2 - Cloudy, 3 - Office, 4 - Home)
  s->set_exposure_ctrl(s, 1);  // 0 = disable , 1 = enable
  s->set_aec2(s, 0);           // 0 = disable , 1 = enable
  s->set_ae_level(s, 0);       // -2 to 2
  //s->set_aec_value(s, 300);    // 0 to 1200
  s->set_gain_ctrl(s, 1);      // 0 = disable , 1 = enable
  //s->set_agc_gain(s, 0);       // 0 to 30
  s->set_gainceiling(s, (gainceiling_t)GAINCEILING_16X);  // 0 to 6
  s->set_bpc(s, 0);            // 0 = disable , 1 = enable
  s->set_wpc(s, 1);            // 0 = disable , 1 = enable
  s->set_raw_gma(s, 1);        // 0 = disable , 1 = enable
  s->set_lenc(s, 1);           // 0 = disable , 1 = enable
  s->set_hmirror(s, 0);        // 0 = disable , 1 = enable
  s->set_vflip(s, 0);          // 0 = disable , 1 = enable
  s->set_dcw(s, 1);            // 0 = disable , 1 = enable
  s->set_colorbar(s, 0);       // 0 = disable , 1 = enable
  delay(1000);

}

void connectWifi()
{

  WiFi.mode(WIFI_STA);
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(ssid);
  WiFi.begin(ssid, password);  
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(500);
  }
  Serial.println();
  Serial.print("ESP32-CAM IP Address: ");
  Serial.println(WiFi.localIP());

}

void setupLedFlash() 
{
    #if CONFIG_LED_ILLUMINATOR_ENABLED
    ledcSetup(LED_LEDC_CHANNEL, 5000, 8);
    ledcAttachPin(LED_GPIO_NUM, LED_LEDC_CHANNEL);
    #else
    Serial.printf("LED flash is disabled -> CONFIG_LED_ILLUMINATOR_ENABLED = 0\n");
    #endif
}

#if CONFIG_LED_ILLUMINATOR_ENABLED
void enable_led(bool en, int led_duty)
{ // Turn LED On or Off
    int duty = en ? led_duty : 0;
    if (en && (led_duty > CONFIG_LED_MAX_INTENSITY)){
      duty = CONFIG_LED_MAX_INTENSITY;
    }
    ledcWrite(LED_LEDC_CHANNEL, duty);
    Serial.printf("Set LED intensity to %d\n", duty);
}
#endif

void print_wakeup_reason(){
  esp_sleep_wakeup_cause_t wakeup_reason;

  wakeup_reason = esp_sleep_get_wakeup_cause();

  switch(wakeup_reason)
  {
    case ESP_SLEEP_WAKEUP_EXT0 : Serial.println("Wakeup caused by external signal using RTC_IO"); break;
    case ESP_SLEEP_WAKEUP_EXT1 : Serial.println("Wakeup caused by external signal using RTC_CNTL"); break;
    case ESP_SLEEP_WAKEUP_TIMER : Serial.println("Wakeup caused by timer"); break;
    case ESP_SLEEP_WAKEUP_TOUCHPAD : Serial.println("Wakeup caused by touchpad"); break;
    case ESP_SLEEP_WAKEUP_ULP : Serial.println("Wakeup caused by ULP program"); break;
    default : Serial.printf("Wakeup was not caused by deep sleep: %d\n",wakeup_reason); break;
  }
}

camera_fb_t * takePhoto(){

  camera_fb_t * fb = NULL;
  fb = esp_camera_fb_get();
  esp_camera_fb_return(fb);
  fb = NULL;
#if CONFIG_LED_ILLUMINATOR_ENABLED
    enable_led(true, LED_INTENSITY);
    delay(150); // The LED needs to be turned on ~150ms before the call to esp_camera_fb_get()
    fb = esp_camera_fb_get();             // or it won't be visible in the frame. A better way to do this is needed.
    enable_led(false, LED_INTENSITY);
#else
    fb = esp_camera_fb_get();
#endif
  if(!fb) {
    Serial.println("Camera capture failed.");
  }
  else{
    Serial.println("Camera capture succeed.");
  }
  return fb;

}

String sendPhoto(camera_fb_t * fb) {
  String getAll;
  String getBody;

  // Print status message
  Serial.println("Connecting to server: " + serverName);

  // Check if connection to the server is successful
  if (client.connect(serverName.c_str(), serverPort)) {
    Serial.println("Connection successful!");

    // Prepare the HTTP POST request headers
    String head = "--MyBoundary\r\nContent-Disposition: form-data; name=\"imageFile\"; filename=\"esp32-cam.jpg\"\r\nContent-Type: image/jpeg\r\n\r\n";
    String tail = "\r\n--MyBoundary--\r\n";

    // Calculate the total length of the request
    uint32_t imageLen = fb->len;
    uint32_t extraLen = head.length() + tail.length();
    uint32_t totalLen = imageLen + extraLen;

    // Send HTTP POST request headers
    client.println("POST " + serverPath + " HTTP/1.1");
    client.println("Host: " + serverName);
    client.println("Content-Length: " + String(totalLen));
    client.println("Content-Type: multipart/form-data; boundary=MyBoundary");
    client.println();
    client.print(head);

    // Send the image data in chunks of 1024 bytes
    uint8_t *fbBuf = fb->buf;
    size_t fbLen = fb->len;
    for (size_t n=0; n<fbLen; n=n+1024) {
      if (n+1024 < fbLen) {
        client.write(fbBuf, 1024);
        fbBuf += 1024;
      }
      else if (fbLen % 1024 > 0) {
        size_t remainder = fbLen % 1024;
        client.write(fbBuf, remainder);
      }
    }   
    // Send the request tail
    client.print(tail);

    // Wait for the server response
    int timoutTimer = 10000;
    long startTimer = millis();
    boolean state = false;
    
    while ((startTimer + timoutTimer) > millis()) {
      Serial.print(".");
      delay(100);      

      // Process server response
      while (client.available()) {
        char c = client.read();
        if (c == '\n') {
          if (getAll.length() == 0) { state = true; }
          getAll = "";
        }
        else if (c != '\r') { getAll += String(c); }
        if (state == true) { getBody += String(c); }
        startTimer = millis();
      }
      // Break if the response body is received
      if (getBody.length() > 0) { break; }
    }
    Serial.println();

    // Close the connection to the server
    client.stop();
    Serial.println(getBody);
  }
  else {
    // Print connection failure message
    getBody = "Connection to " + serverName + " failed.";
    Serial.println(getBody);
  }
  // Return the server response body
  return getBody;
}
