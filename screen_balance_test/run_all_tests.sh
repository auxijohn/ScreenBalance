#!/bin/bash

# Visual colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

REPORT_FILE="test_report.txt"

# Reset/create report file
echo "================================================================" > "$REPORT_FILE"
echo "                ScreenBalance Integration Test Report           " >> "$REPORT_FILE"
echo "                Generated: $(date)" >> "$REPORT_FILE"
echo "================================================================" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

echo -e "${BLUE}================================================================${NC}"
echo -e "${BLUE}        ScreenBalance Automated Scenario Test Runner            ${NC}"
echo -e "${BLUE}================================================================${NC}"
echo ""

TEST_FILES=(
  "integration_test/onboarding_observation_test.dart"
  "integration_test/onboarding_quiz_test.dart"
  "integration_test/boundaries_test.dart"
  "integration_test/login_flow_test.dart"
  "integration_test/real_os_telemetry_test.dart"
  "integration_test/real_scroll_typing_test.dart"
  "integration_test/wellness_dashboard_interaction_test.dart"
)

TEST_NAMES=(
  "Onboarding (7-Day Observation Path)"
  "Onboarding (Instant Quiz Path)"
  "Boundary & Identity Configuration"
  "PIN Auth Login & Profile Logout"
  "Real OS Telemetry Events Simulation"
  "Real Scroll & Typing Telemetry Events"
  "Wellness Dashboard Interactions (Lock Count & Dopamine Loop)"
)

SUCCESS_COUNT=0
FAILURE_COUNT=0

for i in "${!TEST_FILES[@]}"; do
  FILE="${TEST_FILES[$i]}"
  NAME="${TEST_NAMES[$i]}"
  
  echo -e "${YELLOW}Running test [$((i+1))/${#TEST_FILES[@]}]: $NAME...${NC}"
  
  # Run flutter test and capture output to a temp file
  TEMP_LOG=$(mktemp)
  flutter test "$FILE" -d emulator-5554 > "$TEMP_LOG" 2>&1
  EXIT_CODE=$?
  
  if [ $EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✓ PASS: $NAME${NC}"
    echo "PASS: $NAME" >> "$REPORT_FILE"
    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
  else
    echo -e "${RED}✗ FAIL: $NAME${NC}"
    echo "FAIL: $NAME" >> "$REPORT_FILE"
    # Try to extract the failure message from output
    REASON=$(grep -E "expect|AssertionError|TestFailure|Exception" "$TEMP_LOG" | head -n 5)
    if [ -z "$REASON" ]; then
      REASON="Timed out or crashed (Exit Code: $EXIT_CODE)"
    fi
    echo "   Reason: $REASON" >> "$REPORT_FILE"
    echo -e "${RED}   Reason: $REASON${NC}"
    FAILURE_COUNT=$((FAILURE_COUNT + 1))
  fi
  rm "$TEMP_LOG"
  echo "" >> "$REPORT_FILE"
done

echo "================================================================" >> "$REPORT_FILE"
echo "Summary:" >> "$REPORT_FILE"
echo "  Total Tests: ${#TEST_FILES[@]}" >> "$REPORT_FILE"
echo "  Successes: $SUCCESS_COUNT" >> "$REPORT_FILE"
echo "  Failures: $FAILURE_COUNT" >> "$REPORT_FILE"
echo "================================================================" >> "$REPORT_FILE"

echo -e "${BLUE}================================================================${NC}"
echo -e "${BLUE}                      TEST RUN SUMMARY                          ${NC}"
echo -e "${BLUE}================================================================${NC}"
cat "$REPORT_FILE"
echo -e "${BLUE}================================================================${NC}"

if [ $FAILURE_COUNT -gt 0 ]; then
  exit 1
else
  exit 0
fi
