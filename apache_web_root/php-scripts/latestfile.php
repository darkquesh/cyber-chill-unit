<?php
$webRoot = $_SERVER['DOCUMENT_ROOT'];
$runsDirectory = $webRoot . '/detic-runs'; // Assuming detic-runs is in the web root

// Get all files in the directory
$files = scandir($runsDirectory);

// Filter out directories and get only files
$files = array_filter($files, function ($file) use ($runsDirectory) {
    return is_file($runsDirectory . '/' . $file);
});

// Filter files based on naming convention (assuming all files have names in the format Y-m-d\TH-i-s)
$files = array_filter($files, function ($file) {
    return preg_match('/^\d{4}-\d{2}-\d{2}T\d{2}-\d{2}-\d{2}\.(jpg|json|txt)$/', $file);
});

// Sort files by modified time in descending order (latest first)
usort($files, function ($a, $b) use ($runsDirectory) {
    return filemtime($runsDirectory . '/' . $b) - filemtime($runsDirectory . '/' . $a);
});

// Get the name of the latest file without extension
$latestFile = pathinfo(reset($files), PATHINFO_FILENAME);

// Echo the latest file name as JSON
echo json_encode(['latestFile' => $latestFile]);
?>
