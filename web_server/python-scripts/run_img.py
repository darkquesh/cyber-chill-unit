import argparse
import os
import subprocess

if __name__ == '__main__':

    # Create an argument parser
    parser = argparse.ArgumentParser(description='Run demo.py with specific arguments.')

    # Add arguments for input and output file names
    parser.add_argument('--input', required=True, help='Input file name (without path)')
    
    # Parse the command-line arguments
    args = parser.parse_args()

    # Define the Detic folder path
    detic_folder = '/opt/detic_root/Detic'  # Replace with the actual path to your Detic folder

    # Construct the relative paths to the configuration and model files
    config_file = 'configs/Detic_LI_CLIP_SwinB_896b32_4x_ft4x_max-size.yaml'
    model_file = 'models/Detic_LI_CLIP_SwinB_896b32_4x_ft4x_max-size.pth'

    # Define the webroot path
    webroot = '/var/www/html'

    # Define the input and output folders
    input_folder = os.path.join(webroot, 'esp-uploads')
    output_folder = os.path.join(webroot, 'detic-runs')

    # Construct the full file paths for input and output
    input_file = os.path.join(input_folder, args.input)

    # Construct the subprocess command to run demo.py
    cmd = [
        'python3','demo.py',
        '--cpu',
        '--config-file', config_file,
        '--input', input_file,
        '--output', output_folder,
        '--vocabulary', 'lvis',
        '--opts', 'MODEL.WEIGHTS', model_file
    ]

    # Run demo.py with the specified input and output files
    subprocess.call(cmd, cwd=detic_folder)
