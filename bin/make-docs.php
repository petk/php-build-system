#!/usr/bin/env php
<?php

declare(strict_types=1);

/**
 * Generate documentation from the CMake project specific modules where needed.
 *
 * SYNOPSIS:
 *   ./bin/make-docs.php
 */

/**
 * Generate CMake module Markdown docs file from the file's header comment.
 */
function generateModuleDocs(
    string $file,
    string $namespace,
    string $destination,
    string $url,
): void {
    $content = file_get_contents($file);
    preg_match('/^#\[===+\[\s*(.*?)\s*#\]===+\]/s', $content, $matches);

    if (!isset($matches[1])) {
        return;
    }

    $moduleName = basename($file, '.cmake');

    $content = '';
    $content .= "# $namespace" . "$moduleName\n\n";
    $content .= "See: [$moduleName.cmake]($url)\n\n";
    if ($namespace) {
        $content .= <<<EOT
            ## Basic usage

            ```cmake
            include({$namespace}{$moduleName})
            ```
            EOT;
    } elseif (1 === preg_match('/^Find.+.cmake$/', $moduleName)) {
        $content .= <<<EOT
            ## Basic usage

            ```cmake
            find_package($moduleName)
            ```
            EOT;
    } else {
        $content .= <<<EOT
            ## Basic usage

            ```cmake
            include(cmake/$moduleName.cmake)
            ```
            EOT;
    }
    $content .= "\n\n";
    $content .= $matches[1];
    $content .= "\n";

    if (!file_exists($destination)) {
        mkdir($destination, 0777, true);
    }

    $markdownFile = $destination . '/' . $moduleName . '.md';
    if (file_exists($markdownFile)) {
        echo "\nWarning: $markdownFile already exists.\n";
        $markdownFile = $destination . '/' . $moduleName . '_2.md';
        echo "Module has been renamed to $markdownFile\n\n";
    }

    file_put_contents($markdownFile, $content);
}

/**
 * Remove directory contents recursively.
 */
function emptyDirectory(string $path): void
{
    $iterator = new RecursiveIteratorIterator(
        new RecursiveDirectoryIterator($path, RecursiveDirectoryIterator::SKIP_DOTS),
        RecursiveIteratorIterator::CHILD_FIRST,
    );

    foreach ($iterator as $file) {
        if ($file->isDir()) {
            rmdir($file->getPathname());
        } else {
            unlink($file->getPathname());
        }
    }
}

$modulesDocsDir = __DIR__ . '/../docs/cmake/modules';

if (!file_exists($modulesDocsDir)) {
    mkdir($modulesDocsDir, 0777, true);
} else {
    emptyDirectory($modulesDocsDir);
}

$modules = [
    'cmake/modules',
    'cmake/modules/Packages',
    'cmake/modules/PHP',
    'ext/opcache/cmake',
    'ext/posix/cmake',
    'ext/session/cmake',
    'ext/skeleton/cmake/modules/FindPHP.cmake',
    'ext/standard/cmake',
    'sapi/fpm/cmake',
    'sapi/phpdbg/cmake',
    'Zend/cmake',
];

$baseDir = __DIR__ . '/../cmake';

$files = [];
foreach ($modules as $module) {
    if (is_dir($baseDir . '/' . $module)) {
        $foundFiles = glob($baseDir . '/' . $module . '/*.cmake', GLOB_BRACE);
        $files = array_merge($files, $foundFiles);
    } else {
        $files[] = $baseDir . '/' . $module;
    }
}

foreach ($files as $module) {
    $relativeFilename = trim(str_replace($baseDir, '', $module), '/');

    if (str_starts_with($module, $baseDir . '/cmake/modules/')) {
        $namespace = trim(str_replace($baseDir . '/cmake/modules', '', dirname($module)), '/');
        $namespace = ('' == $namespace) ? '' : $namespace . '/';
        $subdir = $namespace;
    } else {
        $namespace = '';
        if ('FindPHP.cmake' === basename($module)) {
            $subdir = '';
        } else {
            $subdir = basename(dirname($module, 2));
        }
    }

    echo "Processing cmake/$relativeFilename\n";
    generateModuleDocs(
        $module,
        $namespace,
        $modulesDocsDir . '/' . $subdir,
        'https://github.com/petk/php-build-system/blob/master/cmake/' . $relativeFilename,
    );
}
