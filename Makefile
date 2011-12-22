
test:
	@./node_modules/.bin/mocha \
		--reporter list \
		--growl

mate:
	@mate src/ test/

.PHONY: test