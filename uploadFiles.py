import requests

def uploadFile(srv_url: str, filename: str, param: str):
    files = {'file': (filename, open(filename, 'rb'))}
    data = {'folder': param}  # Specify the folder parameter here

    response = requests.post(srv_url, files=files, data=data)
    
    print(response.text)

if __name__ == "__main__":
    srv_url = 'http://51.20.72.77/php-scripts/upload.php'  # Replace with your server's URL
    filename = 'orange.jpg'
    param = '--raw'

    uploadFile(srv_url, filename, param)