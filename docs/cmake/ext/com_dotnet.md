<!-- This is auto-generated file. -->
* Source code: [ext/com_dotnet/CMakeLists.txt](https://github.com/petk/php-build-system/blob/master/cmake/ext/com_dotnet/CMakeLists.txt)

# The com_dotnet extension

This extension provides the Component Object Model (COM) and .NET support.

> [!NOTE]
> This extension is available only when the target system is Windows.

## Requirements

To build this extension, Windows SDK needs to be installed, which includes
the COM support.

To enable also the .NET support in this extension (e.g., the `dotnet` PHP
class), the .NET framework needs to be installed, which provides the
`<mscoree.h>` header. This can be done in several ways:

* in Visual Studio by installing the .NET desktop development workload
* in Visual Studio by installing the .NET framework 4.x component only
* Download and install
  [.NET framework](https://dotnet.microsoft.com/en-us/download/dotnet-framework)
  manually.

The .NET version 5 and later are not supported as they have removed the
`<mscoree.h>` API.

## Configuration options

### PHP_EXT_COM_DOTNET

* Default: `ON`
* Values: `ON|OFF`

Enables the extension.

### PHP_EXT_COM_DOTNET_SHARED

* Default: `OFF`
* Values: `ON|OFF`

Builds extension as shared.

### PHP_EXT_COM_DOTNET_ENABLE_DOTNET

* Default: `ON`
* Values: `ON|OFF`

Enables the .NET Framework support.
