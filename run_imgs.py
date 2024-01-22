# run_imgs.py

import os
from pathlib import Path

def beep():
    print("\a")

def run_imgs(main_dir: str, input_dir: str, output_dir: str, file_extension: str = ".jpeg"):
    # Change the directory according to your machine (though it must be in your Detic directory)
    os.chdir(main_dir)
    #model = f"Detic_LCOCOI21k_CLIP_SwinB_896b32_4x_ft4x_max-size"
    #model = f"Detic_LbaseI_CLIP_SwinB_896b32_4x_ft4x_max-size"  # Second best
    #model = f"BoxSup-C2_Lbase_CLIP_SwinB_896b32_4x"
    #model = f"BoxSup-C2_L_CLIP_SwinB_896b32_4x"
    model = f"Detic_LI_CLIP_SwinB_896b32_4x_ft4x_max-size" # Truly the BEST ONE
    #config = f"Detic_LI_CLIP_SwinB_896b32_4x_ft4x_max-size"

    # set the command to execute
    command1 = f"python3 demo.py --config-file configs\{model}.yaml"
    command2 =  f"--opts MODEL.WEIGHTS models\{model}.pth"      #--vocabulary lvis 

    # set the input and output directories
    #input_dir = "runs\input"
    #output_dir = "runs\output"

    # If Status = 0, detection is successful; 1 if fails
    Status = 1

    # iterate through all the files in the input directory
    for i, filename in enumerate(sorted(os.listdir(input_dir), key=lambda f: (''.join(filter(str.isdigit, f))))):
        #print(i+1, filename)
        
        is_file = filename.endswith((file_extension, file_extension.upper()))

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
            Status = 0

        else:
            Status = 1
    
    if Status == 0:
        print("\nObject detection is done!\n")

    json_file = f'{main_dir}\\run_log.json'

    return Status, input_file, output_file, json_file

if __name__ == "__main__":
    main_dir = "C:\\Users\\erenk\\OneDrive\\Desktop\\eren\\ELE401_402\\Detic\\Detic\\"
    #input_dir = "runs\input"
    #output_dir = "runs\output"

    input_dir = "C:\\Users\\erenk\\OneDrive\\Desktop\\eren\\ELE401_402\\mold_model_train\\peach"
    output_dir = "C:\\Users\\erenk\\OneDrive\\Desktop\\eren\\ELE401_402\\mold_model_train\\peach\\detic"
    file_extension = ".jpg"
    
    run_imgs(main_dir, input_dir, output_dir, file_extension)
    beep()  # Alert when done
