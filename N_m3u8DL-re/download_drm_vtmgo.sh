#!/bin/bash

# Pad naar downloader (aangepast naar lokale map)
DOWNLOADER="./N_m3u8DL-RE"
SAVE_DIR="$HOME/Downloads"

echo "======================================"
echo "    Vtmgo Stream Downloader           "
echo "======================================"
echo ""

# Vraag om de MPD URL
read -rp "Voer de MPD URL in: " MPD_URL
if [ -z "$MPD_URL" ]; then
    echo "Fout: MPD URL mag niet leeg zijn."
    exit 1
fi

# Vraag om de KEYS (inclusief --key er al voor)
read -rp "Plak de KEYs (bijv. --key kid:key --key kid:key): " DECRYPTION_KEYS
if [ -z "$DECRYPTION_KEYS" ]; then
    echo "Fout: Keys mogen niet leeg zijn."
    exit 1
fi

# Vraag om de gewenste bestandsnaam
read -rp "Voer de gewenste bestandsnaam in (zonder .mkv): " FILENAME
if [ -z "$FILENAME" ]; then
    echo "Fout: Bestandsnaam mag niet leeg zijn."
    exit 1
fi

echo ""
echo "-> Download wordt gestart..."
echo "-> Opslaglocatie: $SAVE_DIR/$FILENAME.mkv"
echo "======================================"
echo ""

# Het N_m3u8DL-RE commando (met $DECRYPTION_KEYS zonder aanhalingstekens zodat spaties werken)
$DOWNLOADER "$MPD_URL" \
  -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:147.0) Gecko/20100101 Firefox/147.0" \
  -H "Accept: */*" \
  -H "Referer: https://vtmgo.be/" \
  -H "Origin: https://vtmgo.be" \
  $DECRYPTION_KEYS \
  --decryption-engine SHAKA_PACKAGER \
  --decryption-binary-path /usr/bin/shaka-packager \
  --save-dir "$SAVE_DIR" \
  --save-name "$FILENAME" \
  --auto-select \
  -M format=mkv \
  --del-after-done

echo ""
echo "======================================"
echo "Proces voltooid!"
echo "======================================"
