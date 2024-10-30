#[=============================================================================[
Add subdirectories of PHP extensions.
#]=============================================================================]

message(
  STATUS
  "--------------------------
   Configuring PHP extensions
   --------------------------"
)

include(PHP/Extensions)
php_extensions_add(.)
