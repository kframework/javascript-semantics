#!/bin/bash

echo "Installing KJS..."
make

echo
echo "Running core test262..."
make test262-clean
make -k test262-core >test262.out 2>&1
echo "The result was saved at: test262.out"

echo
echo "Running core test262 with measuring semantic coverage..."
( cd test262-coverage
  make test262-clean
  make -k test262-core-coverage >test262-coverage.log 2>&1
  ./coverage.sh >test262-coverage.out 2>&1
)
echo "The result was saved at: test262-coverage/test262-coverage.out"

echo
echo "Detecting security attack..."
( cd security-attack
  make clean
  make >security-attack.out 2>&1
)
echo "The result was saved at: security-attack/security-attack.out"

echo
echo "Verifying example programs..."
( cd verification
  make >verification.out 2>&1
)
echo "The result was saved at: verification/verification.out"
