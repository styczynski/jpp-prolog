all:
	@mkdir -p ./build 2> /dev/null > /dev/null
	cd src && php main.pl > ../build/ps386038.pl && cd ..

test: all
	cd test && php test.pl > ../build/ps386038_test.pl && cd ..
	cd build && cat ./ps386038_test.pl | swipl && cd ..
