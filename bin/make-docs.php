#!/usr/bin/env php
<?php

/**
 * Generate documentation from the CMake project specific modules where needed.
 *
 * SYNOPSIS:
 *   ./bin/make-docs.php
 */

/**
 * Get CMake module header content.
 */
function generateModuleDocs(
    string $file,
    string $namespace,
    string $destination
): void {
    $content = file_get_contents($file);
    preg_match('/^#\[===+\[\s*(.*?)\s*#\]===+\]/s', $content, $matches);

    if (isset($matches[1])) {
        $moduleName = basename($file, '.cmake');

        $content = '';
        $content .= "# $namespace" . "$moduleName\n\n";
        $content .= $matches[1];
        $content .= "\n";

        if (!file_exists($destination . '/' . $namespace)) {
            mkdir($destination . '/' . $namespace, 0777, true);
        }

        file_put_contents(
            $destination . '/' . $namespace . $moduleName . '.md',
            $content
        );
    }
}

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

    $namespace = trim(str_replace($modulesDirectory, '', dirname($file)), '/');
    $namespace = ($namespace == '') ? '' : $namespace . '/';

    generateModuleDocs($file, $namespace, $docs);
}

// Add ext/skeleton/cmake/modules/FindPHP.cmake.
generateModuleDocs(
    __DIR__ . '/../cmake/ext/skeleton/cmake/modules/FindPHP.cmake',
    '',
    $docs
);
