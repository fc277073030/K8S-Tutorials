.PHONY: run
run: ## Start mkdocs server, and watch the files change
	docker run --rm -it -p 8000:8000 -v ${PWD}:/docs squidfunk/mkdocs-material serve -a 0.0.0.0:8000
	#mkdocs serve
.PHONY: build
build: ## Clean previous build content then build static site
	docker run --rm -it -v ${PWD}:/docs squidfunk/mkdocs-material build --clean