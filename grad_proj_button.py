# import module
from selenium import webdriver
from selenium.webdriver.support.select import Select
from selenium.webdriver import ActionChains
import time
import requests
import os

from run_imgs import run_imgs

main_dir = "C:\\Users\\erenk\\OneDrive\\Desktop\\eren\\ELE401_402\\Detic\\Detic\\"
os.chdir(main_dir) # Windows
#os.chdir("/home/nitro/Desktop/image_proc/Detic/")  # Linux
  
# Create the webdriver object. Here the 
# chromedriver is present in the driver 
# folder of the root directory.
driver = webdriver.Firefox()
  
# Camera web server - change it accordingly!
cam_server = "http://192.168.1.26"

# Get webpage
driver.get(cam_server)

# Maximize the window and let code stall 
# for 2s to properly maximise the window.
#driver.maximize_window()
time.sleep(2)

# Select VGA 640x480 resolution
select = Select(driver.find_element("xpath" ,"//select[@id='framesize']"))
select.select_by_value("8")
time.sleep(0.5)

# Increase gain ceiling (exposure)
en = driver.find_element("xpath" ,"//input[@id='gainceiling']")
move = ActionChains(driver)
move.click_and_hold(en).move_by_offset(4, 0).release().perform()
time.sleep(1)

# Get the image
image_url = f'{cam_server}/capture'
img_data = requests.get(image_url).content

try:  
    os.mkdir('ESP32')  
except OSError as error:  
    print(error)

with open('ESP32/image2.jpg', 'wb') as handler:
    handler.write(img_data)

###
###
###

# Change the directory according to your machine (though it must be in your Detic directory)
#os.chdir("/home/nitro/Desktop/image_proc/Detic/")

# set the input and output directories
input_dir = "ESP32\\"
output_dir = "ESP32\\runs\\"
file_extension = ".jpg"

try:  
    os.mkdir(output_dir)  
except OSError as error:  
    print(error)

run_imgs(main_dir, input_dir, output_dir, file_extension)


'''  
# Obtain button by link text and click.
button = driver.find_element("xpath" ,"//*[contains(text(), 'Get Still')]")
button.click()
time.sleep(1)

button2 = driver.find_element("xpath" ,"//*[contains(text(), 'Save')]")
button2.click()
time.sleep(1)
'''