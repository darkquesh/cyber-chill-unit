# import module
from selenium import webdriver
from selenium.webdriver.support.select import Select
import time
import requests
import os

os.chdir("/home/nitro/Desktop/image_proc/Detic/")
  
# Create the webdriver object. Here the 
# chromedriver is present in the driver 
# folder of the root directory.
driver = webdriver.Firefox()
  
# get webpage
driver.get("http://10.42.0.206")

# Maximize the window and let code stall 
# for 2s to properly maximise the window.
#driver.maximize_window()
time.sleep(2)

select=Select(driver.find_element("xpath" ,"//select[@class='default-action']"))
select.select_by_index(0)
time.sleep(0.5)

image_url = 'http://10.42.0.206/capture'

img_data = requests.get(image_url).content
with open('ESP/image2.jpg', 'wb') as handler:
    handler.write(img_data)

###
###
###

# Change the directory according to your machine (though it must be in your Detic directory)
#os.chdir("/home/nitro/Desktop/image_proc/Detic/")

# set the command to execute
command1 = "python3 demo.py --config-file configs/Detic_LCOCOI21k_CLIP_SwinB_896b32_4x_ft4x_max-size.yaml"
command2 =  "--vocabulary lvis --opts MODEL.WEIGHTS models/Detic_LCOCOI21k_CLIP_SwinB_896b32_4x_ft4x_max-size.pth"

# set the input and output directories
input_dir = "/home/nitro/Desktop/image_proc/Detic/ESP/"
output_dir = "/home/nitro/Desktop/image_proc/Detic/ESP/runs/1/"

# iterate through all the files in the input directory
for i, filename in enumerate(sorted(os.listdir(input_dir))):#, key=lambda f: int(''.join(filter(str.isdigit, f))))):
    #print(i+1, filename)
    
    if filename.endswith(".jpg"):
        # set the input and output file paths
        input_file = os.path.join(input_dir, filename)
        output_file = os.path.join(output_dir, "out{}.jpg".format(i+1))

        # execute the command with the input and output file paths
        os.system("{} --input {} --output {} {}".format(command1, input_file, output_file, command2))


'''  
# Obtain button by link text and click.
button = driver.find_element("xpath" ,"//*[contains(text(), 'Get Still')]")
button.click()
time.sleep(1)

button2 = driver.find_element("xpath" ,"//*[contains(text(), 'Save')]")
button2.click()
time.sleep(1)
'''