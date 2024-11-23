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
 * Remove directory contents recursively.
 */
function emptyDirectory(string $path): void
{
    if (!file_exists($path)) {
        return;
    }

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

/**
 * Generate CMake module Markdown docs file from the file's header comment.
 */
function generateModuleDocs(
    string $file,
    string $namespace,
    string $destination,
): void {
    if (!file_exists($file)) {
        return;
    }

    $code = file_get_contents($file);
    preg_match('/^#\[===+\[\s*(.*?)\s*#\]===+\]/s', $code, $matches);

    if (!isset($matches[1])) {
        return;
    }

    $moduleName = basename($file, '.cmake');
    $content = $matches[1];

    $relativeFilename = trim(str_replace(realpath(__DIR__ . '/../cmake'), '', realpath($file)), '/');
    $url = 'https://github.com/petk/php-build-system/blob/master/cmake/' . $relativeFilename;

    $markdown = "<!-- This is auto-generated file. -->\n";
    $markdown .= "* Source code: [$relativeFilename]($url)\n\n";
    $markdown .= $content . "\n";

    if ($namespace) {
        $footer = <<<EOT
            ## Basic usage

            ```cmake
            # CMakeLists.txt
            include({$namespace}{$moduleName})
            ```
            EOT;
    } elseif (1 === preg_match('/^Find(.+)$/', $moduleName, $matches)) {
        $findPackageName = $matches[1] ?? null;
        $findPackageUpper = strtoupper($findPackageName);

        $footer = <<<EOT
            ## Basic usage

            ```cmake
            # CMakeLists.txt
            find_package($findPackageName)
            ```
            EOT;

        $footer_2 = <<<EOT
            ## Customizing search locations

            To customize where to look for the $findPackageName package base
            installation directory, a common `CMAKE_PREFIX_PATH` or
            package-specific `{$findPackageUpper}_ROOT` variable can be set at
            the configuration phase. For example:

            ```sh
            cmake -S <source-dir> \
                  -B <build-dir> \
                  -DCMAKE_PREFIX_PATH="/opt/$findPackageName;/opt/some-other-package"
            # or
            cmake -S <source-dir> \
                  -B <build-dir> \
                  -D{$findPackageUpper}_ROOT=/opt/$findPackageName \
                  -DSOMEOTHERPACKAGE_ROOT=/opt/some-other-package
            ```
            EOT;
    } else {
        $footer = <<<EOT
            ## Basic usage

            ```cmake
            # CMakeLists.txt
            include(cmake/$moduleName.cmake)
            ```
            EOT;
    }

    if (1 !== preg_match('/## Basic usage[\r\n]/', $content, $matches)) {
        $markdown .= "\n" . $footer . "\n";
    }

    if (isset($footer_2)) {
        $markdown .= "\n" . $footer_2 . "\n";
    }

    if (!file_exists($destination)) {
        mkdir($destination, 0777, true);
    }

    $markdownFile = realpath($destination) . '/' . $moduleName . '.md';
    if (file_exists($markdownFile)) {
        echo "\nWarning: $markdownFile already exists.\n";
        $markdownFile = $destination . '/' . $moduleName . '_2.md';
        echo "Documentation file has been renamed to $markdownFile\n\n";
    }

    echo "Generating $markdownFile\n";
    file_put_contents($markdownFile, $markdown);
}

/**
 * Generate Markdown documentation from the extension or SAPI CMakeLists.txt
 * header comment.
 */
function generateDocs(
    string $file,
    string $destination,
): void {
    if (!file_exists($file)) {
        return;
    }

    $code = file_get_contents($file);
    preg_match('/^#\[===+\[\s*(.*?)\s*#\]===+\]/s', $code, $matches);

    if (!isset($matches[1])) {
        return;
    }

    $content = $matches[1];

    $relativeFilename = trim(str_replace(realpath(__DIR__ . '/../cmake'), '', realpath($file)), '/');
    $url = 'https://github.com/petk/php-build-system/blob/master/cmake/' . $relativeFilename;

    $markdown = "<!-- This is auto-generated file. -->\n";
    $markdown .= "* Source code: [$relativeFilename]($url)\n\n";
    $markdown .= $content . "\n";

    if (!file_exists(dirname($destination))) {
        mkdir(dirname($destination), 0777, true);
    }

    echo 'Generating ' . $destination . "\n";
    file_put_contents($destination, $markdown);
}

/*
 * Generate documentation for CMake modules.
 */

emptyDirectory(__DIR__ . '/../docs/cmake/modules');

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

foreach ($files as $file) {
    if (str_starts_with($file, $baseDir . '/cmake/modules/')) {
        $namespace = trim(str_replace($baseDir . '/cmake/modules', '', dirname($file)), '/');
        $namespace = ('' == $namespace) ? '' : $namespace . '/';
        $subdir = $namespace;
    } else {
        $namespace = '';
        if ('FindPHP.cmake' === basename($file)) {
            $subdir = '';
        } else {
            $subdir = basename(dirname($file, 2));
        }
    }

    generateModuleDocs(
        $file,
        $namespace,
        __DIR__ . '/../docs/cmake/modules/' . $subdir,
    );
}

/*
 * Generate documentation for PHP SAPIs and extensions.
 */

emptyDirectory(__DIR__ . '/../docs/cmake/ext');
emptyDirectory(__DIR__ . '/../docs/cmake/sapi');

$files = glob(__DIR__ . '/../cmake/{ext,sapi}/*/CMakeLists.txt', GLOB_BRACE);

foreach ($files as $file) {
    $destination = __DIR__
        . '/../docs/cmake/'
        . basename(dirname($file, 2))
        . '/'
        . basename(dirname($file))
        . '.md';
    generateDocs($file, $destination);
}

// Generate PEAR docs.
generateDocs(__DIR__ . '/../cmake/pear/CMakeLists.txt', __DIR__ . '/../docs/cmake/pear.md');
