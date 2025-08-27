SHELL := bash
.ONESHELL:
.SHELLFLAGS := -euo pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables

## help		: Quick help/reminder
help : Makefile
	@sed -n 's/^##//p' $<