import os
import subprocess
import numpy as np
import torch
import torch.nn as nn
from torchvision import transforms
from torchvision.utils import save_image
from PIL import Image
import json
# import matplotlib.pyplot as plt

# conv_block
class conv_block(nn.Module):
    def __init__(self, in_c, out_c):
        super().__init__()
        self.conv1 = nn.Conv2d(in_c, out_c, kernel_size=3, padding=1)
        self.bn1 = nn.BatchNorm2d(out_c)
        self.conv2 = nn.Conv2d(out_c, out_c, kernel_size=3, padding=1)
        self.bn2 = nn.BatchNorm2d(out_c)
        self.relu = nn.ReLU()

    def forward(self, inputs):
        x = self.conv1(inputs)
        x = self.bn1(x)
        x = self.relu(x)
        x = self.conv2(x)
        x = self.bn2(x)
        x = self.relu(x)
        return x

# encoder_block
class encoder_block(nn.Module):
    def __init__(self, in_c, out_c):
        super().__init__()
        self.conv = conv_block(in_c, out_c)
        self.pool = nn.MaxPool2d((2, 2))

    def forward(self, inputs):
        x = self.conv(inputs)
        p = self.pool(x)
        return x, p

# decoder block
class decoder_block(nn.Module):
    def __init__(self, in_c, out_c):
        super().__init__()
        self.up = nn.ConvTranspose2d(
            in_c, out_c, kernel_size=2, stride=2, padding=0
        )
        self.conv = conv_block(out_c + out_c, out_c)

    def forward(self, inputs, skip):
        x = self.up(inputs)
        x = torch.cat([x, skip], axis=1)
        x = self.conv(x)
        return x

# Build U-Net
class build_unet(nn.Module):
    def __init__(self):
        super().__init__()
        """ Encoder """
        self.e1 = encoder_block(3, 64)
        self.e2 = encoder_block(64, 128)
        self.e3 = encoder_block(128, 256)
        self.e4 = encoder_block(256, 512)
        """ Bottleneck """
        self.b = conv_block(512, 1024)
        """ Decoder """
        self.d1 = decoder_block(1024, 512)
        self.d2 = decoder_block(512, 256)
        self.d3 = decoder_block(256, 128)
        self.d4 = decoder_block(128, 64)
        """ Classifier """
        self.outputs = nn.Conv2d(64, 1, kernel_size=1, padding=0)

    def forward(self, inputs):
        """Encoder"""
        s1, p1 = self.e1(inputs)
        s2, p2 = self.e2(p1)
        s3, p3 = self.e3(p2)
        s4, p4 = self.e4(p3)
        """ Bottleneck """
        b = self.b(p4)
        """ Decoder """
        d1 = self.d1(b, s4)
        d2 = self.d2(d1, s3)
        d3 = self.d3(d2, s2)
        d4 = self.d4(d3, s1)
        """ Classifier """
        outputs = self.outputs(d4)
        return outputs


if __name__ == "__main__":

    # # Define the transformations for testing/validation
    # test_transform = transforms.Compose(
    #     [
    #         transforms.Resize((296, 296)),
    #         transforms.CenterCrop((224, 224)),
    #         transforms.ToTensor(),
    #     ]
    # )

    # Define the transformations for testing/validation
    test_transform = transforms.Compose(
        [
            transforms.Resize((224, 224)),
            transforms.ToTensor(),
        ]
    )

    ## Define Paths

    webroot = "/var/www/html/"
    path_image_rot = os.path.join(webroot, 'esp-uploads-rot/')

    ## Transform image
    
    basename_image_rot = "esp32-cam"
    image_rot = Image.open(path_image_rot + basename_image_rot + ".jpg").convert("RGB")
    image_rot_resized = test_transform(image_rot)
    filename_image_rot_resized = path_image_rot + basename_image_rot + "_resized.jpg"
    save_image(image_rot_resized, filename_image_rot_resized)

    ## ---RUN DETIC---

    detic_folder = "/opt/detic_root/Detic" 

    # Construct the relative paths to the configuration and model files
    detic_config_file = "configs/Detic_LI_CLIP_SwinB_896b32_4x_ft4x_max-size.yaml"
    detic_model_file = "models/Detic_LI_CLIP_SwinB_896b32_4x_ft4x_max-size.pth"

    # Define the input file and output folder
    detic_input_file = filename_image_rot_resized   
    detic_output_folder = os.path.join(webroot, 'detic-runs-rot/')  

    cmd = [
        "python3", "demo-rot.py",
        "--cpu",
        "--config-file", detic_config_file,
        "--input", detic_input_file,
        "--output", detic_output_folder,
        "--opts",
        "MODEL.WEIGHTS", detic_model_file
    ]

    # Run demo.py with the specified input and output files
    subprocess.call(cmd, cwd=detic_folder)

    ## -------- Calculate the spoiling rate --------

    # Load Model

    path_model = "/opt/models/"
    filename_model = os.path.join(path_model, 'mold_model_bce.pth')
    model_1 = build_unet()
    checkpoint_1 = torch.load(filename_model, map_location=torch.device('cpu'))
    model_1.load_state_dict(checkpoint_1)
    model_1.to("cpu")

    # Inference Image

    image_inference = image_rot_resized
    preds_rot = torch.sigmoid(model_1(image_inference.unsqueeze(0)))
    preds_rot = preds_rot.cpu().detach().squeeze().numpy()
    preds_rot = np.where(preds_rot >= 0.5, 1, 0)

    ############

    # Draw image with mask
    image_inference = image_inference.permute(1, 2, 0).numpy()
    image_mask = image_inference.copy()
    pred_indices_rot = np.where(preds_rot == 1)
    
    image_mask[pred_indices_rot[0], pred_indices_rot[1], :] = [0, 0, 1]
    image_mask_uint8 = (image_mask * 255).astype(np.uint8)

    path_image_mask = detic_output_folder + basename_image_rot + "-mask.jpg"
    Image.fromarray(image_mask_uint8).save(path_image_mask)

    #################

    ## Load .pt File

    fruit_directory = detic_output_folder
    _ , fruit_filename = os.path.split(filename_image_rot_resized)
    detic_pt_file = os.path.join(fruit_directory, os.path.splitext(fruit_filename)[0] + '.pt')
    pred_fruit = torch.load(detic_pt_file)["pred_masks"]
    pred_fruit_np = pred_fruit.squeeze().cpu().detach().numpy()
    pred_fruit_np = pred_fruit_np.astype(int)

    count_fruit_mask = np.count_nonzero(pred_fruit_np == 1)
    count_rot_mask = np.count_nonzero(preds_rot == 1)
    spoiling_rate = round(100 * count_rot_mask / count_fruit_mask, 2)
    
    print(f"# of Rotten Pixels: {count_rot_mask}")
    print(f"# of Fruit Pixels: {count_fruit_mask}")
    print(f"Spoiling rate: {spoiling_rate}%")

    ## Export JSON
    json_file_path = os.path.join(fruit_directory, 'esp32-cam.json')
    json_dict = {"spoiling_rate": str(spoiling_rate)}

    # Dump string to JSON file
    with open(json_file_path, "w") as json_file:
        json.dump(json_dict, json_file)
