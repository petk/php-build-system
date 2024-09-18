#!/usr/bin/env php
<?php

/**
 * Generate documentation from the CMake project specific modules where needed.
 *
 * SYNOPSIS:
 *   ./bin/make-docs.php
 */

$docs = __DIR__ . '/../docs/cmake-modules';
if (!file_exists($docs)) {
    mkdir($docs, 0777, true);
}

$docFiles = glob($docs . '/*{/*,*}', GLOB_BRACE);
foreach ($docFiles as $file) {
    if (is_file($file)) {
        unlink($file);
    }
}

$modulesDirectory = realpath(__DIR__ . '/../cmake/cmake/modules');
$files = glob($modulesDirectory . '/*{/*,*}.cmake', GLOB_BRACE);

foreach ($files as $file) {
    $relativeFilename = trim(str_replace($modulesDirectory, '', $file), '/');
    echo "Processing " . $relativeFilename . "\n";

    $content = file_get_contents($file);
    preg_match('/#\[===+\[\s*(.*?)\s*#\]===+\]/s', $content, $matches);

    if (isset($matches[1])) {
        $moduleName = basename($file, '.cmake');
        $namespace = trim(str_replace($modulesDirectory, '', dirname($file)), '/');
        $namespace = ($namespace == '') ? '' : $namespace . '/';

        $content = '';
        $content .= "# $namespace" . "$moduleName\n\n";
        $content .= $matches[1];
        $content .= "\n";

        if (!file_exists($docs . '/' . $namespace)) {
            mkdir($docs . '/' . $namespace, 0777, true);
        }

        file_put_contents($docs . '/' . $namespace . $moduleName . '.md', $content);
    }
}
