<?php

$target_dir = $_SERVER['DOCUMENT_ROOT'] . "/esp-uploads-rot/";
$target_file = $target_dir . basename($_FILES["imageFile"]["name"]);
$uploadOk = 1;
$imageFileType = strtolower(pathinfo($target_file, PATHINFO_EXTENSION));

// Check if image file is an actual image or a fake image
if (isset($_POST["submit"])) {
  $check = getimagesize($_FILES["imageFile"]["tmp_name"]);
  if ($check !== false) {
    echo "File is an image - " . $check["mime"] . ".";
    $uploadOk = 1;
  } else {
    echo "File is not an image.";
    $uploadOk = 0;
  }
}

// Check file size
if ($_FILES["imageFile"]["size"] > 10 * 1024 * 1024) {
  echo "Sorry, your file is too large.";
  $uploadOk = 0;
}

// Allow certain file formats
if ($imageFileType != "jpg" && $imageFileType != "png" && $imageFileType != "jpeg" && $imageFileType != "gif") {
  echo "Sorry, only JPG, JPEG, PNG, & GIF files are allowed.";
  $uploadOk = 0;
}

// Check if $uploadOk is set to 0 due to an error
if ($uploadOk == 0) {
  echo "Sorry, your file was not uploaded.";
} else {
  if (move_uploaded_file($_FILES["imageFile"]["tmp_name"], $target_file)) {
    echo "The file " . basename($_FILES["imageFile"]["name"]) . " has been uploaded.";

    // Add the code to trigger the Python script here

    $pythonScript = $_SERVER['DOCUMENT_ROOT'] . "/python-scripts/run_img-rot.py";
    $inputImage = $target_file;
    $outputImage = $target_file;
    $command = "python3 $pythonScript > /dev/null 2>&1 &";
    exec($command);
    echo "Python script is running in the background.";

  } else {
    echo "Sorry, there was an error uploading your file.";
  }
}
?>
