.PHONY: test test-unit test-integration test-coverage install install-dev clean lint

install:
	pipenv install

install-dev:
	pipenv install --dev

test:
	pipenv run pytest

test-unit:
	pipenv run pytest tests/test_process_pane.py tests/test_ztop.py

test-integration:
	pipenv run pytest tests/test_integration.py

test-coverage:
	pipenv run coverage run -m pytest
	pipenv run coverage report
	pipenv run coverage html

lint:
	pipenv run python -m py_compile ztop.py

clean:
	find . -type f -name "*.pyc" -delete
	find . -type d -name "__pycache__" -delete
	rm -rf htmlcov/
	rm -f .coverage