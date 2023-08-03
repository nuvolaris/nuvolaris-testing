#!/bin/bash
set -e

# config
nuv config reset

# deploy
nuv setup devcluster
