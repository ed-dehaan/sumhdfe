* ===========================================================================
* Reinstall and run all tests
* ===========================================================================

	do setup


	* Basic tests to ensure it runs
	do test-simple-1
	do test-simple-2
	do test-simple-3
	do test-histogram

	* Tests to ensure it runs *correctly*
	do test-validate-1


* Success
	di as text "No errors found!"
	clear
	exit
