#!/bin/sh
set -o pipefail
set -e

sh build-package-network-diagnosis-framework-noswift.sh
sh build-package-network-diagnosis-framework.sh
sh build-package-network-diagnosis-noswift.sh
sh build-package-network-diagnosis.sh
