#include <sapi/embed/php_embed.h>

int main(int argc, char **argv)
{
	/* Invoke the Zend Engine initialization phase: SAPI (SINIT), modules
	 * (MINIT), and request (RINIT). It also opens a 'zend_try' block to catch a
	 * zend_bailout().
	 */
	PHP_EMBED_START_BLOCK(argc, argv)

	php_printf(
		"Number of functions loaded: %d\n",
		zend_hash_num_elements(EG(function_table))
	);

	/* Close the 'zend_try' block and invoke the shutdown phase: request
	 * (RSHUTDOWN), modules (MSHUTDOWN), and SAPI (SSHUTDOWN).
	 */
	PHP_EMBED_END_BLOCK()
}
