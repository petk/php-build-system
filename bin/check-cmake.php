#!/usr/bin/env php
<?php

declare(strict_types=1);

/**
 * Helper script for checking code style issues.
 */

/**
 * Get script usage.
 */
function usage(string $script): string
{
    return <<<EOL
    CMake code checker

    Checks project files for code style issues and runs external checking tools.

    Reports redundant and missing CMake module include() invocations. It follows
    the philosophy of "include what you use" - each CMake file should include
    only those modules of which commands are used in it. Transitive includes
    should be avoided. For example, where a CMake module is included in one
    CMake file and it is then transitively used in other files via nested
    includes or similar.

    SYNOPSIS:
        $script [<options>] <path>

    OPTIONS:
        -h, --help                Display this help and exit.
        --gersemi                 Run gersemi.
        --cmakelint               Run cmakelint.
        --cmakelang-cmake-format  Run cmake-format by cmakelang project.
        --cmakelang-cmake-lint    Run cmake-lint by cmakelang project.

    FEATURES:
        - Reports missing and unused CMake find and utility modules
        - Runs codespell, normalizator, gersemi, and cmakelang tools if found
    EOL;
}

/**
 * Echo given message and append a newline character.
 */
function output(string $message = ''): void
{
    echo $message . "\n";
}

/**
 * Get options from the command line arguments.
 */
function options(array $overrides = [], array $argv = []): array
{
    static $options;

    if (isset($options)) {
        $options = array_merge($options, $overrides);

        return $options;
    }

    $shortOptions = 'h';

    $longOptions = [
        'help',
        'gersemi',
        'cmakelint',
        'cmakelang-cmake-format',
        'cmakelang-cmake-lint',
    ];

    $optionsIndex = null;
    $cliOptions = getopt($shortOptions, $longOptions, $optionsIndex);

    $options = [
        'help' => false,
        'path' => null,
        'script' => pathinfo($argv[0], PATHINFO_BASENAME),
        'gersemi' => false,
        'cmakelint' => false,
        'cmakelang-cmake-format' => false,
        'cmakelang-cmake-lint' => false,
    ];

    foreach ($cliOptions as $option => $value) {
        switch ($option) {
            case 'h':
            case 'help':
                $options['help'] = true;
                break;
            case 'gersemi':
                $options['gersemi'] = true;
                break;
            case 'cmakelint':
                $options['cmakelint'] = true;
                break;
            case 'cmakelang-cmake-format':
                $options['cmakelang-cmake-format'] = true;
                break;
            case 'cmakelang-cmake-lint':
                $options['cmakelang-cmake-lint'] = true;
                break;
        }
    }

    if (count($argv) < 2) {
        $options['help'] = true;
    }

    foreach (array_slice($argv, $optionsIndex) as $file) {
        if (file_exists($file) && $file !== $argv[0]) {
            $options['path'] = realpath($file);

            break;
        }
    }

    validateOptions($options);

    return $options;
}

/**
 * Validate command-line options and arguments.
 */
function validateOptions(array $options): void
{
    // Check for help.
    if ($options['help']) {
        output(usage($options['script']));
        exit(1);
    }

    // Check if path exists.
    if (
        !array_key_exists('path', $options)
        || null === $options['path']
        || !file_exists($options['path'])
    ) {
        output('Path argument missing');
        output();
        output(usage($options['script']));
        exit(1);
    }
}

/**
 * Get all project modules.
 */
function getProjectModules(): array
{
    return  [
        'CheckCCompilerFlag' => ['check_c_compiler_flag'],
        'CheckCompilerFlag' => ['check_compiler_flag'],
        'CheckCSourceCompiles' => ['check_c_source_compiles'],
        'CheckCSourceRuns' => ['check_c_source_runs'],
        'CheckCXXCompilerFlag' => ['check_cxx_compiler_flag'],
        'CheckCXXSourceCompiles' => ['check_cxx_source_compiles'],
        'CheckCXXSourceRuns' => ['check_cxx_source_runs'],
        'CheckCXXSymbolExists' => ['check_cxx_symbol_exists'],
        'CheckFunctionExists' => ['check_function_exists'],
        'CheckIncludeFile' => ['check_include_file'],
        'CheckIncludeFileCXX' => ['check_include_file_cxx'],
        'CheckIncludeFiles' => ['check_include_files'],
        'CheckIPOSupported' => ['check_ipo_supported'],
        'CheckLanguage' => ['check_language'],
        'CheckLibraryExists' => ['check_library_exists'],
        'CheckLinkerFlag' => ['check_linker_flag'],
        'CheckPrototypeDefinition' => ['check_prototype_definition'],
        'CheckSourceCompiles' => ['check_source_compiles'],
        'CheckSourceRuns' => ['check_source_runs'],
        'CheckStructHasMember' => ['check_struct_has_member'],
        'CheckSymbolExists' => ['check_symbol_exists'],
        'CheckTypeSize' => ['check_type_size'],
        'CheckVariableExists' => ['check_variable_exists'],
        'CMakeDependentOption' => ['cmake_dependent_option'],
        'CMakePushCheckState' => [
            'cmake_pop_check_state',
            'cmake_push_check_state',
            'cmake_reset_check_state',
        ],
        'ExternalProject' => [
            'ExternalProject_Add',
            'ExternalProject_Add_Step',
            'ExternalProject_Add_StepDependencies',
            'ExternalProject_Add_StepTargets',
            'ExternalProject_Get_Property',
        ],
        'FeatureSummary' => [
            'add_feature_info',
            'feature_summary',
            'set_package_properties',
        ],
        'FetchContent' => [
            'FetchContent_Declare',
            'FetchContent_GetProperties',
            'FetchContent_MakeAvailable',
            'FetchContent_Populate',
            'FetchContent_SetPopulated',
        ],
        'FindPackageHandleStandardArgs' => [
            'find_package_check_version',
            'find_package_handle_standard_args',
        ],
        'FindPackageMessage' => ['find_package_message'],
        'ProcessorCount' => ['processorcount'],
        'PHP/AddCustomCommand' => ['php_add_custom_command'],
        'PHP/CheckAttribute' => [
            'php_check_function_attribute',
            'php_check_variable_attribute',
        ],
        'PHP/CheckCompilerFlag' => ['php_check_compiler_flag'],
        'PHP/ConfigureFile' => ['php_configure_file'],
        'PHP/Install' => ['php_install'],
        'PHP/PkgConfigGenerator' => ['pkgconfig_generate_pc'],
        'PHP/SearchLibraries' => ['php_search_libraries'],
        'PHP/SystemExtensions' => ['PHP::SystemExtensions'],
    ];
}

/**
 * Return filtered CMake code without single and multi-line comments.
 *
 * Hash characters (#) inside quotes (") are not supported until more advanced
 * parsing is needed.
 */
function getCMakeCode(SplFileInfo $file): string
{
    $content = file_get_contents($file->getRealPath());
    $content = preg_replace('/\#\[[=]*\[.*?\][=]*\]/s', '', $content);
    $content = preg_replace('/[ \t]*#.*$/m', '', $content);

    return $content;
}

/**
 * Get all CMake files.
 */
function getAllCMakeFiles(string $path): Iterator
{
    if (is_file($path)) {
        $info = new SplFileInfo($path);

        return new ArrayIterator([$info->getPathname() => $info]);
    }

    $directoryIterator = new RecursiveDirectoryIterator($path, RecursiveDirectoryIterator::SKIP_DOTS);
    $recursiveIterator = new RecursiveIteratorIterator(new RecursiveCallbackFilterIterator(
        $directoryIterator,
        function ($current, $key, $iterator) {
            // Allow recursion.
            if ($iterator->hasChildren()) {
                return true;
            }

            if (
                1 === preg_match('/\.cmake$/', $current->getBasename())
                || in_array($current->getBasename(), [
                    'CMakeLists.txt',
                    'CMakeLists.txt.in',
                ], true)
            ) {
                return true;
            }

            return false;
        },
    ));

    $items = [];
    foreach ($recursiveIterator as $item) {
        $items[$item->getPathname()] = $item;
    }

    return new ArrayIterator($items);
}

/**
 * Check given CMake files for include() issues.
 */
function checkCMakeFiles(Iterator $files, array $modules): int
{
    $status = 0;

    foreach ($files as $file) {
        $content = getCMakeCode($file);

        // Check for redundant includes.
        foreach ($modules as $module => $commands) {
            $hasModule = false;
            $moduleEscaped = str_replace('/', '\/', $module);

            if (1 === preg_match('/^[ \t]*include[ \t]*\(' . $moduleEscaped . '[ \t]*\)/m', $content)) {
                $hasModule = true;
            }

            $hasCommand = false;
            foreach ($commands as $command) {
                if (
                    (
                        1 === preg_match('/::/', $command)
                        && 1 === preg_match('/[^A-Za-z0-9_]' . $command . '[^A-Za-z0-9_]/m', $content)
                    )
                    || 1 === preg_match('/^[ \t]*' . $command . '[ \t]*\(/m', $content)
                ) {
                    $hasCommand = true;
                    break;
                }
            }

            // Skip current file if it is the current module itself.
            $prefix = pathinfo(dirname($file->getRealPath()), PATHINFO_FILENAME);
            $prefix = ('cmake' === $prefix) ? '' : $prefix . '/';
            $moduleNameFromFile = $prefix . pathinfo($file->getRealPath(), PATHINFO_FILENAME);

            if ($moduleNameFromFile == $module) {
                continue;
            }

            if ($hasModule && !$hasCommand) {
                $status = 1;
                output("E: redundant include($module) in $file");
            }

            if (!$hasModule && $hasCommand) {
                $status = 1;
                output("E: missing include($module) in $file");
            }
        }
    }

    return $status;
};

/**
 * Find all local Find* modules in the project.
 */
function getFindModules(string $path): Iterator
{
    if (is_file($path)) {
        $info = new SplFileInfo($path);

        return new ArrayIterator([$info->getPathname() => $info]);
    }

    $directoryIterator = new RecursiveDirectoryIterator($path, RecursiveDirectoryIterator::SKIP_DOTS);
    $recursiveIterator = new RecursiveIteratorIterator(new RecursiveCallbackFilterIterator(
        $directoryIterator,
        function ($current, $key, $iterator) {
            // Allow recursion.
            if ($iterator->hasChildren()) {
                return true;
            }

            if (preg_match('/^Find.*\.cmake$/', $current->getFilename())) {
                return true;
            }

            return false;
        },
    ));

    $items = [];
    foreach ($recursiveIterator as $item) {
        $items[$item->getPathname()] = $item;
    }

    return new ArrayIterator($items);
}

/**
 * Check for unused Find*.cmake modules.
 */
function checkFindModules(Iterator $findModules, Iterator $allCMakeFiles): int
{
    $status = 0;

    foreach ($findModules as $module) {
        preg_match('/^Find(.*)\.cmake$/', $module->getFilename(), $matches);
        $package = (array_key_exists(1, $matches)) ? $matches[1] : '';

        $found = false;
        foreach ($allCMakeFiles as $file) {
            $content = getCMakeCode($file);
            if (1 === preg_match('/find_package[ \t]*\([ \t\n\r]*' . $package . '[ \t\n\r\)]/', $content)) {
                $found = true;
                break;
            }
        }

        if (!$found) {
            $status = 1;
            output("E: unused find module $module");
        }
    }

    return $status;
};

/**
 * Find all local CMake modules in the project.
 */
function getModules(string $path): Iterator
{
    if (is_file($path)) {
        $info = new SplFileInfo($path);

        return new ArrayIterator([$info->getPathname() => $info]);
    }

    $directoryIterator = new RecursiveDirectoryIterator($path, RecursiveDirectoryIterator::SKIP_DOTS);
    $recursiveIterator = new RecursiveIteratorIterator(new RecursiveCallbackFilterIterator(
        $directoryIterator,
        function ($current, $key, $iterator) {
            // Allow recursion.
            if ($iterator->hasChildren()) {
                return true;
            }

            if (preg_match('/^Find.*\.cmake$/', $current->getFilename())) {
                return false;
            }

            return true;
        },
    ));

    $items = [];
    foreach ($recursiveIterator as $item) {
        $items[$item->getPathname()] = $item;
    }

    return new ArrayIterator($items);
}

/**
 * Check for unused CMake modules.
 */
function checkModules(Iterator $modules, Iterator $allCMakeFiles): int
{
    $status = 0;

    foreach ($modules as $module) {
        $moduleName = $module->getBasename('.cmake');
        $prefix = pathinfo(dirname($module->getRealPath()), PATHINFO_FILENAME);
        $prefix = (1 === preg_match('/cmake|modules/', $prefix)) ? '' : $prefix . '/';
        $moduleNameEscaped = str_replace('/', '\/', $prefix . $moduleName);
        $moduleBasename = $module->getBasename();
        $moduleBasenameEscaped = str_replace('.', '\.', $moduleBasename);

        $found = false;
        foreach ($allCMakeFiles as $file) {
            $content = getCMakeCode($file);

            // Check if module is included with include().
            if (1 === preg_match('/include[ \t]*\([ \t\n\r]*' . $moduleNameEscaped . '[ \t\n\r\)]/', $content)) {
                $found = true;
                break;
            }

            // Check if module is some artifact and used by its filename.
            if (1 === preg_match('/' . $moduleBasenameEscaped . '/', $content)) {
                $found = true;
                break;
            }
        }

        if (!$found) {
            $status = 1;
            output("E: unused utility module $module");
        }
    }

    return $status;
};

/**
 * Check if terminal command exists.
 */
function checkCommand(string $command): bool
{
    $which = (\PHP_OS == 'WINNT') ? 'where' : 'which';

    $process = \proc_open(
        "$which $command",
        [
            0 => ['pipe', 'r'], // STDIN
            1 => ['pipe', 'w'], // STDOUT
            2 => ['pipe', 'w'], // STDERR
        ],
        $pipes,
    );

    if (false !== $process) {
        $stdout = stream_get_contents($pipes[1]);
        $stderr = stream_get_contents($pipes[2]);
        fclose($pipes[1]);
        fclose($pipes[2]);
        proc_close($process);

        return '' != $stdout;
    }

    return false;
}

/**
 * Check and run codespell tool.
 */
function runCodespell(): int
{
    if (!checkCommand('codespell')) {
        output(<<<EOL

            The 'codespell' tool not found.
            For checking common misspellings, install codespell:
            https://github.com/codespell-project/codespell

        EOL);

        return 0;
    }

    exec(
        'codespell --config ' . __DIR__ . '/check-cmake/.codespellrc .',
        $output,
        $status,
    );

    $output = implode("\n", $output);
    if ('' !== $output) {
        output($output);
        output();
    }

    return $status;
}

/**
 * Check and run normalizator tool.
 */
function runNormalizator(): int
{
    if (!checkCommand('normalizator')) {
        output(<<<EOL

            The 'normalizator' tool not found.
            For checking common code style issues, install normalizator:
            https://github.com/petk/normalizator

        EOL);

        return 0;
    }

    exec(
        'normalizator check --not php-src --not .git ' . __DIR__ . '/..',
        $output,
        $status,
    );

    $output = implode("\n", $output);
    if ('' !== $output) {
        output($output);
        output();
    }

    return $status;
}

/**
 * Check and run gersemi tool.
 */
function runGersemi(): int
{
    if (!checkCommand('gersemi')) {
        output(<<<EOL

            The 'gersemi' tool not found.
            For checking CMake code style, install gersemi:
            https://github.com/BlankSpruce/gersemi

        EOL);

        return 0;
    }

    exec(
        'gersemi --check --indent 2 --definitions cmake bin -- cmake bin',
        $output,
        $status,
    );

    $output = implode("\n", $output);
    if ('' !== $output) {
        output($output);
        output();
    }

    return $status;
}

/**
 * Check and run CMakeLint.
 */
function runCMakeLint(Iterator $files): int
{
    if (!checkCommand('cmakelint')) {
        output(<<<EOL

            The 'cmakelint' tool not found.
            For checking CMake code style, install cmakelint:
            https://github.com/cmake-lint/cmake-lint

        EOL);

        return 0;
    }

    $argument = implode(' ', iterator_to_array($files));
    exec(
        'cmakelint --filter=-linelength,-whitespace/indent,-convention/filename,-package/stdargs ' . $argument,
        $output,
        $status,
    );

    $output = implode("\n", $output);
    if ('' !== $output) {
        output($output);
        output();
    }

    return $status;
}

/**
 * Check and run cmake-format by cmakelang project.
 */
function runCMakeLangCMakeFormat(Iterator $files): int
{
    if (!checkCommand('cmake-format')) {
        output(<<<EOL

            The 'cmake-format' tool not found.
            For checking CMake code style, install cmakelang:
            https://cmake-format.readthedocs.io

        EOL);

        return 0;
    }

    $argument = implode(' ', iterator_to_array($files));
    exec(
        'cmake-format --config-files bin/check-cmake/cmake-format.json --check -- ' . $argument,
        $output,
        $status,
    );

    $output = implode("\n", $output);
    if ('' !== $output) {
        output($output);
        output();
    }

    return $status;
}

/**
 * Check and run cmake-lint by the cmakelang project.
 */
function runCMakeLangCMakeLint(Iterator $files): int
{
    if (!checkCommand('cmake-lint')) {
        output(<<<EOL

            The 'cmake-lint' tool not found.
            For checking CMake code style, install cmakelang:
            https://cmake-format.readthedocs.io

        EOL);

        return 0;
    }

    $argument = implode(' ', iterator_to_array($files));
    exec(
        'cmake-lint --config-files bin/check-cmake/cmake-format.json --suppress-decorations -- ' . $argument,
        $output,
        $status,
    );

    $output = implode("\n", $output);
    if ('' !== $output) {
        output($output);
        output();
    }

    return $status;
}

/**
 * Run all checks.
 */
function checkAll(array $options): int
{
    $status = 0;

    output($options['script'] . ': Working tree ' . $options['path']);

    output($options['script'] . ': Checking CMake modules');
    $allCMakeFiles = getAllCMakeFiles($options['path']);

    $projectModules = getProjectModules();
    $status = checkCMakeFiles($allCMakeFiles, $projectModules);

    $findModules = getFindModules($options['path'] . '/cmake/modules');
    $newStatus = checkFindModules($findModules, $allCMakeFiles);
    $status = (0 === $status) ? $newStatus : $status;

    $modules = getModules($options['path'] . '/cmake/modules');
    $newStatus = checkModules($modules, $allCMakeFiles);
    $status = (0 === $status) ? $newStatus : $status;

    if (0 !== $status) {
        output();
    }

    output($options['script'] . ': Running codespell');
    $newStatus = runCodespell();
    $status = (0 === $status) ? $newStatus : $status;

    output($options['script'] . ': Running normalizator');
    $newStatus = runNormalizator();
    $status = (0 === $status) ? $newStatus : $status;

    if ($options['gersemi']) {
        output($options['script'] . ': Running gersemi');
        $newStatus = runGersemi();
        $status = (0 === $status) ? $newStatus : $status;
    }

    if ($options['cmakelint']) {
        output($options['script'] . ': Running cmakelint');
        $newStatus = runCMakeLint($allCMakeFiles);
        $status = (0 === $status) ? $newStatus : $status;
    }

    if ($options['cmakelang-cmake-format']) {
        output($options['script'] . ': Running cmakelang\'s cmake-format');
        $newStatus = runCMakeLangCMakeFormat($allCMakeFiles);
        $status = (0 === $status) ? $newStatus : $status;
    }

    if ($options['cmakelang-cmake-lint']) {
        output($options['script'] . ': Running cmakelang\'s cmake-lint');
        $newStatus = runCMakeLangCMakeLint($allCMakeFiles);
        $status = (0 === $status) ? $newStatus : $status;
    }

    if (0 === $status) {
        output("\n" . $options['script'] . ': Done');
    }

    return $status;
}

/**
 * Script initialization entry.
 */
function init(array $argv): int
{
    $cwd = getcwd();
    chdir(__DIR__ . '/..');

    $options = options([], $argv);

    $status = checkAll($options);

    chdir($cwd);

    return $status;
}

exit(init($argv));
