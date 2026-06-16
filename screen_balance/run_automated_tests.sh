#!/bin/bash

# Exit on error
set -e

# Visual colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================================================${NC}"
echo -e "${BLUE}        ScreenBalance Automated UI Integration Test Runner       ${NC}"
echo -e "${BLUE}================================================================${NC}"
echo ""

echo -e "${YELLOW}[1/3] Checking for active devices or emulators...${NC}"

# Check connected devices
DEVICES=$(flutter devices)

# We want to see if there are any devices.
# A typical flutter devices output when no devices are connected contains "No devices found"
# Or if it only lists web/chrome, we check if there's any mobile or desktop target.
echo "Connected Flutter Devices:"
echo "$DEVICES"
echo ""

if echo "$DEVICES" | grep -q "No devices found"; then
  echo -e "${RED}ERROR: No running emulator, simulator, or physical device was detected.${NC}"
  echo -e "${YELLOW}Please start your Android Emulator, iOS Simulator, or connect a physical device, and try again.${NC}"
  exit 1
fi

echo -e "${GREEN}✓ Devices detected successfully!${NC}"
echo ""

echo -e "${YELLOW}[2/3] Resolving dependencies and checking packages...${NC}"
flutter pub get
echo -e "${GREEN}✓ Packages synchronized.${NC}"
echo ""

echo -e "${YELLOW}[3/3] Running automated UI test suite on the emulator screen...${NC}"
echo -e "${BLUE}Note: Watch your simulator/emulator screen as the test automates clicks and text entries live!${NC}"
echo ""

# Run the integration test
set +e
flutter test integration_test/app_test.dart
TEST_EXIT_CODE=$?
set -e

echo ""
echo -e "${BLUE}================================================================${NC}"
if [ $TEST_EXIT_CODE -eq 0 ]; then
  echo -e "${GREEN}🎉 SUCCESS: All automated integration test scenarios passed!${NC}"
  exit 0
else
  echo -e "${RED}❌ FAILURE: Some integration test scenarios failed or timed out.${NC}"
  echo -e "${YELLOW}Please review the terminal log output above for failures.${NC}"
  exit $TEST_EXIT_CODE
fi
echo -e "${BLUE}================================================================${NC}"
