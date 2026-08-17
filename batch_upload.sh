#!/bin/bash
# Laedt alle Dateien im aktuellen Ordner in Gruppen (Batches) zu GitHub hoch.
# Nutzt 'find ... -print0', um auch mit Leerzeichen und Sonderzeichen (z.B. @)
# in Dateinamen zuverlaessig umzugehen - das war die Fehlerquelle vorher.

BATCH_SIZE=100

# Alle Dateien im aktuellen Ordner sammeln (ohne .git-Ordner und versteckte Dateien)
files=()
while IFS= read -r -d '' f; do
  files+=("$f")
done < <(find . -maxdepth 1 -type f ! -name ".*" -print0)

echo "Gefundene Dateien: ${#files[@]}"

count=0
batch=()
batch_num=0

for f in "${files[@]}"; do
  batch+=("$f")
  count=$((count+1))

  if [ "$count" -ge "$BATCH_SIZE" ]; then
    batch_num=$((batch_num+1))
    echo "--- Batch $batch_num: $count Dateien ---"
    git add -- "${batch[@]}"
    git commit -m "Batch Upload $batch_num ($count Dateien)"
    git push origin main
    batch=()
    count=0
  fi
done

# Restliche Dateien (letzter, kleinerer Batch)
if [ "${#batch[@]}" -gt 0 ]; then
  batch_num=$((batch_num+1))
  echo "--- Letzter Batch $batch_num: ${#batch[@]} Dateien ---"
  git add -- "${batch[@]}"
  git commit -m "Batch Upload $batch_num (Rest: ${#batch[@]} Dateien)"
  git push origin main
fi

echo "Fertig! Alle Dateien wurden in Batches hochgeladen."
