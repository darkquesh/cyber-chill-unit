<?php

$target_dir = $_SERVER['DOCUMENT_ROOT'] . "/esp-uploads/";
$server_timestamp = time();
$utc_difference = 3;
$adjusted_timestamp = $server_timestamp + ($utc_difference * 3600);
$target_file = $target_dir . date('Y-m-d\TH-i-s', $adjusted_timestamp) . '.jpg';
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

// Check if the file already exists
if (file_exists($target_file)) {
  echo "Sorry, file already exists.";
  $uploadOk = 0;
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
    echo "The file has been uploaded.";

    // Add the code to trigger the Python script here

    $pythonScript = $_SERVER['DOCUMENT_ROOT'] . "/python-scripts/run_img.py";
    $inputImage = $target_file;
    $command = "python3 $pythonScript --input $inputImage > /dev/null 2>&1 &";
    exec($command);
    echo "Python script is running in the background.";

  } else {
    echo "Sorry, there was an error uploading your file.";
  }
}
?>
