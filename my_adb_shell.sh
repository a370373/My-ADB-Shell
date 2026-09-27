#!/data/data/com.termux/files/usr/bin/bash

clear

echo "======================================"
echo "        My ADB Shell / UID 2000"
echo "======================================"
echo

ADB="/data/data/com.termux/files/usr/bin/adb"

if [ ! -x "$ADB" ]; then
    echo "[ERROR] ADB not found:"
    echo "$ADB"
    exit 1
fi

echo "[+] Using Termux ADB:"
"$ADB" version
echo

# ============================================================
# Pairing
# ============================================================

while true; do

    echo "--------------------------------------"
    echo " Wireless Debugging Pairing"
    echo "--------------------------------------"

    read -r -p "Pairing IP:Port : " PAIR_ADDR

    if [ -z "$PAIR_ADDR" ]; then
        echo "[!] Empty address."
        echo
        continue
    fi

    read -r -p "Please enter your verify code : " VERIFY_CODE

    if [ -z "$VERIFY_CODE" ]; then
        echo "[!] Empty verification code."
        echo
        continue
    fi

    PAIR_SUCCESS=0

    echo
    echo "[+] Trying pairing..."
    echo

    for ATTEMPT in $(seq 1 100); do

        echo "[Pair attempt $ATTEMPT/100]"

        PAIR_OUTPUT="$("$ADB" pair "$PAIR_ADDR" "$VERIFY_CODE" 2>&1)"
        PAIR_STATUS=$?

        echo "$PAIR_OUTPUT"

        if [ "$PAIR_STATUS" -eq 0 ] &&
           ! echo "$PAIR_OUTPUT" | grep -qiE \
           "failed|error|wrong password|connection was dropped|connection reset|protocol fault"; then

            PAIR_SUCCESS=1
            echo
            echo "[+] Pairing SUCCESS."
            break
        fi

        "$ADB" kill-server >/dev/null 2>&1
        "$ADB" start-server >/dev/null 2>&1

        sleep 1
    done

    if [ "$PAIR_SUCCESS" -eq 1 ]; then
        break
    fi

    echo
    echo "[!] All 100 pairing attempts failed."
    echo "[!] Please enter a new pairing address/code."
    echo
done

# ============================================================
# Automatic connection discovery
# ============================================================

echo
echo "======================================"
echo " Searching for ADB connection..."
echo "======================================"
echo

CONNECT_ADDR=""

# ------------------------------------------------------------
# 1. Let ADB try its own automatic discovery first
# ------------------------------------------------------------

echo "[+] Checking adb devices..."

DEVICES_OUTPUT="$("$ADB" devices 2>/dev/null)"

echo "$DEVICES_OUTPUT"

FOUND_DEVICE="$(echo "$DEVICES_OUTPUT" | awk '
    NR > 1 && $2 == "device" {
        print $1
        exit
}')"

if [ -n "$FOUND_DEVICE" ]; then
    CONNECT_ADDR="$FOUND_DEVICE"
    echo
    echo "[+] Device automatically discovered:"
    echo "$CONNECT_ADDR"
fi

# ------------------------------------------------------------
# 2. If automatic discovery failed, try localhost ports
# ------------------------------------------------------------

if [ -z "$CONNECT_ADDR" ]; then

    echo
    echo "[+] Automatic discovery did not find the device."
    echo "[+] Searching local ADB connection ports..."

    # Use nmap when available.
    if command -v nmap >/dev/null 2>&1; then

        echo "[+] nmap detected."
        echo "[+] Scanning localhost ports 30000-50000..."

        OPEN_PORTS="$(
            nmap -sT -p30000-50000 --open 127.0.0.1 2>/dev/null |
            awk '/^[0-9]+\/tcp[[:space:]]+open/ {split($1,a,"/"); print a[1]}'
        )"

        for PORT in $OPEN_PORTS; do

            echo "[+] Trying localhost:$PORT"

            CONNECT_OUTPUT="$(
                "$ADB" connect "127.0.0.1:$PORT" 2>&1
            )

            echo "$CONNECT_OUTPUT"

            if echo "$CONNECT_OUTPUT" | grep -qiE \
                "connected to|already connected"; then

                CONNECT_ADDR="127.0.0.1:$PORT"

                echo
                echo "[+] ADB connection found:"
                echo "$CONNECT_ADDR"

                break
            fi

        done

    else
        echo "[!] nmap is not installed."
        echo "[!] Cannot automatically scan the local dynamic ADB ports."
    fi
fi

# ------------------------------------------------------------
# 3. Verify connection
# ------------------------------------------------------------

if [ -z "$CONNECT_ADDR" ]; then
    echo
    echo "[ERROR] Could not automatically find ADB connection."
    echo
    echo "Pairing succeeded, but the ADB connection port"
    echo "could not be discovered."
    echo
    echo "Your device is paired; this is NOT a pairing failure."
    exit 1
fi

echo
echo "======================================"
echo " Verifying UID 2000..."
echo "======================================"
echo

ID_OUTPUT="$(
    "$ADB" -s "$CONNECT_ADDR" shell id 2>/dev/null |
    tr -d '\r'
)"

echo "$ID_OUTPUT"

if echo "$ID_OUTPUT" | grep -q 'uid=2000(shell)'; then

    echo
    echo "======================================"
    echo " SUCCESS"
    echo " UID 2000 shell obtained."
    echo "======================================"
    echo

    exec "$ADB" -s "$CONNECT_ADDR" shell

else

    echo
    echo "[ERROR] Connected, but UID 2000 was not confirmed."
    echo
    exit 1
fi
