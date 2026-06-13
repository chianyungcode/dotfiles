#!/usr/bin/env bash

declare -A SERVERS=(
  ["Symphony SG - Singapore"]="62530"
  ["ION Network SG - Singapore"]="63375"
  ["CBN - Singapore"]="59016"
  ["MyRepublic Singapore - Singapore"]="5935"
  ["M1 Limited - Singapore"]="7311"
  ["Firstmedia - Singapore"]="7556"
  ["fdcservers.net - Singapore"]="26654"
  ["PT. Mora Telematika Indonesia - Singapore"]="47713"
  ["PT XLSMART Telecom Sejahtera - Jakarta"]="68900"
  ["PT Netciti Persada - Tangerang"]="70657"
  ["PT. Indosat Tbk - Tangerang"]="71476"
  ["Misqot Access - Tangerang"]="69070"
  ["PT Smartfren - Tangerang"]="4210"
  ["GRASI MEDIA RAJEG - Tangerang"]="70123"
  ["PT. Telekomunikasi Indonesia - Tangerang"]="72387"
  ["AIS NET - Tangerang"]="74212"
  ["DeFastNet - Tangerang"]="74981"
  ["Trans Media Data - Tangerang"]="74663"
  ["Telkomsel - Tangerang"]="70715"
  ["CBN - Jakarta"]="12807"
  ["JSN Jaringanku - Jakarta"]="33263"
)

selected=$(
  printf "%s\n" "${!SERVERS[@]}" |
    gum filter --no-limit --placeholder "Cari server..." --header "Pilih server yang ingin di-test:"
)

while read -r name; do
  [[ -z "$name" ]] && continue

  echo "================================"
  echo "Testing Server: $name"
  echo "ID: ${SERVERS[$name]}"
  echo "================================"

  speedtest -s "${SERVERS[$name]}"
  echo
done <<<"$selected"
