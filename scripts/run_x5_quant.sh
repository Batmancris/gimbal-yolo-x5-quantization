#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="/home/demo/tianbot_ws"
VENV_DIR="${ROOT_DIR}/.venv_oe_py310"
HB_MAPPER_BIN="${VENV_DIR}/bin/hb_mapper"

if [[ ! -x "$HB_MAPPER_BIN" ]]; then
  echo "hb_mapper is not installed at: $HB_MAPPER_BIN"
  exit 1
fi

# Usage: run_x5_quant.sh <config.yaml>
# If no argument given, show available configs and exit.
if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <config.yaml>"
  echo ""
  echo "Available configs:"
  echo "  Vehicle: models/vehicle_yolov8n_x5_640/config/x5_quant_best_nv12.yaml"
  echo "  Bear:    models/bear_yolov8n_x5_640/config/x5_quant_bear_nv12.yaml"
  exit 1
fi

CFG="$1"

if [[ ! -f "$CFG" ]]; then
  echo "Config file not found: $CFG"
  exit 1
fi

export HOME="${ROOT_DIR}"
export MPLCONFIGDIR="/tmp/matplotlib-x5"
export HORIZON_LIB_PATH="${ROOT_DIR}/.horizon"
export DDK_LIB_PATH="${ROOT_DIR}/.horizon/ddk"
export X5_X86_GCC1140_PATH="${ROOT_DIR}/.horizon/ddk/x5_x86_64_gcc_11.4.0"
export LD_LIBRARY_PATH="${ROOT_DIR}/.horizon/ddk/x5_x86_64_gcc_11.4.0/dnn_x86/lib:${VENV_DIR}/lib/python3.10/site-packages/hbdk4/runtime/x86_64_unknown_linux_gnu/nash/lib:${LD_LIBRARY_PATH:-}"
export HB_DNN_SIM_PLATFORM="BAYESE"
export PATH="${VENV_DIR}/bin:${PATH}"

# Extract model path from YAML config (onnx_model field)
MODEL_PATH=$(grep 'onnx_model:' "$CFG" | sed "s/.*onnx_model:[[:space:]]*['\"]*//;s/['\"]*$//")
if [[ -z "$MODEL_PATH" || ! -f "$MODEL_PATH" ]]; then
  echo "Cannot find onnx_model from config: $CFG"
  exit 1
fi

echo "[1/2] Checking ONNX compatibility"
"$HB_MAPPER_BIN" checker --model-type onnx --model "$MODEL_PATH" --march bayes-e

echo "[2/2] Building quantized bin"
"$HB_MAPPER_BIN" makertbin --config "$CFG" --model-type onnx

echo "Done. Output is under the working_dir configured inside:"
echo "  $CFG"
