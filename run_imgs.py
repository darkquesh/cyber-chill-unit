# run_imgs.py

import os
from pathlib import Path

def run_imgs(main_dir: str, input_dir: str, output_dir: str, file_extension: str = ".jpeg"):
    # Change the directory according to your machine (though it must be in your Detic directory)
    os.chdir(main_dir)

    # set the command to execute
    command1 = "python3 demo.py --config-file configs\Detic_LCOCOI21k_CLIP_SwinB_896b32_4x_ft4x_max-size.yaml"
    command2 =  "--vocabulary lvis --opts MODEL.WEIGHTS models\Detic_LCOCOI21k_CLIP_SwinB_896b32_4x_ft4x_max-size.pth"

    # set the input and output directories
    #input_dir = "runs\input"
    #output_dir = "runs\output"

    # iterate through all the files in the input directory
    for i, filename in enumerate(sorted(os.listdir(input_dir), key=lambda f: (''.join(filter(str.isdigit, f))))):
        #print(i+1, filename)
        
        is_file = filename.endswith(file_extension)

        if i==1:
            print("\nDetecting objects...")
        
        if is_file:
            # set the input and output file paths
            #print(f"Inside if!, main_dir={main_dir}")
            input_file = os.path.join(input_dir, filename)
            #print(input_file)
            output_file = os.path.join(output_dir, "{}_detic{}.jpg".format(Path(filename).stem, i+1))
            #print(output_file)

            # execute the command with the input and output file paths
            os.system("{} --input {} --output {} {}".format(command1, input_file, output_file, command2))
            #print("If iteration:", i)
    
    print("\nObject detection is done!\n")

if __name__ == "__main__":
    main_dir = "C:\\Users\\erenk\\OneDrive\\Desktop\\eren\\ELE401_402\\Detic\\Detic\\"
    input_dir = "runs\input"
    output_dir = "runs\output"
    file_extension = ".jpeg"
    
    run_imgs(main_dir, input_dir, output_dir, file_extension)
