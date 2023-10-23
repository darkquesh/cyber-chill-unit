import requests

url = 'http://51.20.72.77/php-scripts/upload.php'  # Replace with your server's URL
filename = 'orange.jpg'
files = {'file': (filename, open(filename, 'rb'))}
data = {'folder': '--raw'}  # Specify the folder parameter here

response = requests.post(url, files=files, data=data)

print(response.text)
