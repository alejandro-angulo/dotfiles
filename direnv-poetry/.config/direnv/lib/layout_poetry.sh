#!/bin/bash

layout_poetry() {
  if [[ ! -f pyproject.toml ]]; then
    # shellcheck disable=SC2016
    log_error 'No pyproject.toml found.  Use `poetry new` or `poetry init` to create one first.'
    exit 2
  fi

  local VENV
  VENV=$(poetry env list --full-path | cut -d' ' -f1)
  if [[ -z $VENV || ! -d $VENV/bin ]]; then
    # shellcheck disable=SC2016
    log_error 'No created poetry virtual environment found.  Use `poetry install` to create one first.'
    exit 2
  fi
  VENV=$VENV/bin
  VIRTUAL_ENV=$(echo "$VENV" | rev | cut -d'/' -f2- | rev)
  export VIRTUAL_ENV
  export POETRY_ACTIVE=1
  PATH_add "$VENV"
}
