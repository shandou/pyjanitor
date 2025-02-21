SHELL=/bin/bash
dockercompose_file=docker-compose.yml
ACTIVATE=source activate pyjanitor-dev

dockercompose=docker compose --file $(dockercompose_file)

docker-up: $(dockercompose_file)
	$(dockercompose) up --build --detach


docker-down: $(dockercompose_file)
	$(dockercompose) down --remove-orphans

# Start an existing container
docker-start: ${dockercompose_file}
	${dockercompose} start -it


release:
	rm -f dist/*
	python setup.py sdist bdist_wheel
	twine upload dist/*

# Note to self:
# makefile has not been fully tested.
# DO NOT COMMIT until testing is done.
#
# ALSO, remove this comment once it's tested!!!!!!!!!!!

.PHONY: format test lint docs isort check style notebooks install

format:
	@echo "Applying Black Python code formatting..."
	black -l 79 .

test:
	@echo "Running test suite..."
	pytest -v -n auto --color=yes

lint:
	@echo "Checking code formatting..."
	flake8 . --exclude "./nbconvert_config.py, ./env, ./venv ./build"

docs:
	@echo "Building documentation..."
	cd docs && make html

isort:
	@echo "Sorting imports..."
	isort --check-only --use-parentheses --trailing-comma --multi-line 3 --line-length 79 .

check: test docs notebooks isort format lint
	@echo "checks complete"

style: isort format
	@echo "styling complete"

install:
	@echo "Creating Conda environment..."
	conda env create -f environment-dev.yml

	@echo "Installing PyJanitor in development mode..."
	$(ACTIVATE) && python setup.py develop

	@echo "Registering current virtual environment as a Jupyter Python kernel..."
	$(ACTIVATE) && python -m ipykernel install --user --name pyjanitor-dev --display-name "PyJanitor development"

	@echo "Installing pre-commit hooks"
	$(ACTIVATE) && pre-commit install
