import os
from pathlib import Path

# Change the directory according to your machine (though it must be in your Detic directory)
os.chdir("C:\\Users\\erenk\\OneDrive\\Desktop\\eren\\ELE401\\Detic\\Detic\\")

# set the command to execute
command1 = "python3 demo.py --config-file configs\Detic_LCOCOI21k_CLIP_SwinB_896b32_4x_ft4x_max-size.yaml"
command2 =  "--vocabulary lvis --opts MODEL.WEIGHTS models\Detic_LCOCOI21k_CLIP_SwinB_896b32_4x_ft4x_max-size.pth"

# set the input and output directories
input_dir = "runs\input"
output_dir = "runs\output"

# iterate through all the files in the input directory
for i, filename in enumerate(sorted(os.listdir(input_dir), key=lambda f: (''.join(filter(str.isdigit, f))))):
    #print(i+1, filename)
    file_extension = filename.endswith(".jpeg")
    print("Entered for loop")
    
    if file_extension:
        # set the input and output file paths
        input_file = os.path.join(input_dir, filename)
        output_file = os.path.join(output_dir, "{}_detic{}.jpg".format(Path(filename).stem, i+1))

        # execute the command with the input and output file paths
        os.system("{} --input {} --output {} {}".format(command1, input_file, output_file, command2))
        print("If iteration:", i)

        
