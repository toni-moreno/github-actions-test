#!/bin/bash
awk -v rel=$1 '/^# $rel/{flag=1; next } /^# v/{flag=0} flag' CHANGELOG.md 
