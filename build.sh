#!/data/data/com.termux/files/usr/bin/sh
set -eu

PROJECT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SOURCE_DIR=$(CDPATH= cd -- "$PROJECT_DIR/../lilypad-brincadeira" && pwd)
SDK_DIR=/data/data/com.termux/files/home/.cache/android-api/android-35
RESOURCE_SDK_DIR=/data/data/com.termux/files/home/.cache/android-api/android-9
TOOLS_DIR=/data/data/com.termux/files/usr/bin
OUT="$PROJECT_DIR/build"
ASSET_DIR="$PROJECT_DIR/assets/lilypad-brincadeira"
KEYSTORE="$PROJECT_DIR/lilypad-release.keystore"
RES_COMPILED="$OUT/res-compiled.zip"
RES_APK="$OUT/resources.apk"
GEN="$OUT/gen"
CLASSES="$OUT/classes"
DEX="$OUT/dex"

rm -rf "$OUT" "$ASSET_DIR"
mkdir -p "$GEN" "$CLASSES" "$DEX" "$PROJECT_DIR/assets"
cp -R "$SOURCE_DIR/." "$ASSET_DIR"

"$TOOLS_DIR/aapt2" compile --dir "$PROJECT_DIR/res" -o "$RES_COMPILED"
"$TOOLS_DIR/aapt2" link \
    -I "$RESOURCE_SDK_DIR/android.jar" \
    --manifest "$PROJECT_DIR/AndroidManifest.xml" \
    --java "$GEN" \
    --min-sdk-version 24 \
    --target-sdk-version 35 \
    --version-code 1 \
    --version-name 1.0.0 \
    --auto-add-overlay \
    -o "$RES_APK" -R "$RES_COMPILED"

find "$PROJECT_DIR/src" "$GEN" -type f -name '*.java' -print > "$OUT/sources.list"
javac --release 8 -encoding UTF-8 \
    -classpath "$SDK_DIR/android.jar" \
    -d "$CLASSES" \
    @"$OUT/sources.list"

jar cf "$OUT/classes.jar" -C "$CLASSES" .
"$TOOLS_DIR/d8" --release --min-api 24 --lib "$SDK_DIR/android.jar" \
    --output "$DEX" "$OUT/classes.jar"

cp "$RES_APK" "$OUT/unsigned.apk"
jar uf "$OUT/unsigned.apk" -C "$DEX" classes.dex
jar uf "$OUT/unsigned.apk" -C "$PROJECT_DIR" assets
"$TOOLS_DIR/zipalign" -f -p 4 "$OUT/unsigned.apk" "$OUT/Lilypad-Brincadeira-aligned.apk"

if [ ! -f "$KEYSTORE" ]; then
    keytool -genkeypair -noprompt \
        -keystore "$KEYSTORE" \
        -storepass lilypad \
        -keypass lilypad \
        -alias lilypad \
        -keyalg RSA -keysize 2048 -validity 10000 \
        -dname "CN=Lilypad Brincadeira, OU=Local, O=Lilypad, L=Local, ST=Local, C=BR"
fi

"$TOOLS_DIR/apksigner" sign \
    --ks "$KEYSTORE" \
    --ks-pass pass:lilypad \
    --key-pass pass:lilypad \
    --out "$OUT/Lilypad-Brincadeira.apk" \
    "$OUT/Lilypad-Brincadeira-aligned.apk"

"$TOOLS_DIR/apksigner" verify --verbose "$OUT/Lilypad-Brincadeira.apk"
DOCUMENTS_DIR=/storage/emulated/0/Documents
DOWNLOADS_DIR=/storage/emulated/0/Download
mkdir -p "$DOCUMENTS_DIR" "$DOWNLOADS_DIR"
cp "$OUT/Lilypad-Brincadeira.apk" "$DOCUMENTS_DIR/Lilypad-Brincadeira.apk"
cp "$OUT/Lilypad-Brincadeira.apk" "$DOWNLOADS_DIR/Lilypad-Brincadeira.apk"
printf 'APK criado: %s\n' "$OUT/Lilypad-Brincadeira.apk"
printf 'APK copiado para: %s\n' "$DOCUMENTS_DIR/Lilypad-Brincadeira.apk"
printf 'APK copiado para: %s\n' "$DOWNLOADS_DIR/Lilypad-Brincadeira.apk"
