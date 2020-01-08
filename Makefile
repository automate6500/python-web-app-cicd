APP    = target-app
SCOPE  = user99
TAG    = $(shell echo "$$(date +%F)-$$(git rev-parse --short HEAD)")

help:
	@echo "Run make <target> where target is one of the following..."
	@echo
	@echo "    pip         - install required libraries"
	@echo "    lint        - run flake8 and pylint"
	@echo "    unittest    - run unittests"
	@echo "    build       - build docker container"
	@echo "    run         - run containter on host port 5000"
	@echo "    interactive - run container interactively on host port 5000"
	@echo "    clean       - stop local container, clean up workspace"

pip:
	pip install --quiet --upgrade --requirement requirements.txt

lint:
	flake8 --ignore=E501,E231 *.py
	pylint --errors-only --disable=C0301 --disable=C0326 *.py

unittest:
	python -m unittest --verbose --failfast

build: pip lint unittest
	docker build -t $(SCOPE)/$(APP):$(TAG) .

run: build
	docker run --rm -d -p 5000:5000 --name $(APP) $(SCOPE)/$(APP):$(TAG)

interactive: build
	docker run --rm -it -p 5000:5000 --name $(APP) $(SCOPE)/$(APP):$(TAG)

clean:
	docker container stop $(APP) || true
	@rm -rf ./__pycache__ ./tests/__pycache__
	@rm -f .*~ *.pyc

.PHONY: build clean deploy help interactive lint pip run test unittest upload
