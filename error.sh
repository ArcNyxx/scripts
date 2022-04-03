#!/bin/sh
# error - error function
# Copyright (C) 2022 ArcNyxx
# see LICENCE file for licensing information

error() { echo "$1"; exit ${2:-1} }
