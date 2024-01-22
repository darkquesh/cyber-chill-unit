<?php
$folderPath = 'detic-runs/';

// Get a list of files in the folder
$files = scandir($folderPath);

// Loop through the files and delete them
foreach ($files as $file) {
    // Check if the file is not a directory (directories can't be deleted with unlink)
    if (is_file($folderPath . $file)) {
        if (unlink($folderPath . $file)) {
            echo "Deleted file: " . $folderPath . $file . "<br>";
        } else {
            echo "Failed to delete file: " . $folderPath . $file . "<br>";
        }
    }
}
?>
