.PHONY: all litners flake8 reoder black black-ci black-check black-diff formatters formatters-ci

.NOTPARALLEL:

all: formatters linters

linters: flake8

formatters: reorder black

formatters-ci: reorder black-ci

define BLACK
	python -m black $(1) -l 80 `find . ! -path '*/\.*' -name '*.py'`
endef

flake8:
	@echo "Running flake8"
	python -m flake8 --max-line-length=80 --ignore=E231,W503 `find . ! -path '*/\.*' -name '*.py'`

black:
	@echo "Running black"
	$(call BLACK,)

black-ci:
	make black-check || ( make black-diff; exit 1)

black-check:
	@echo "Running black with check"
	$(call BLACK,--check)

black-diff:
	@echo "Running black with diff"
	$(call BLACK,--diff)

reorder:
	@echo "Running reorder-python-imports"
	reorder-python-imports `find . ! -path '*/\.*' -name '*.py'`
