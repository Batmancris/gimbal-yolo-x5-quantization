#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="/home/demo/tianbot_ws"
MODEL_PATH="${ROOT_DIR}/best.onnx"
NV12_CFG="${ROOT_DIR}/x5_quant_best_nv12.yaml"
RGB_CFG="${ROOT_DIR}/x5_quant_best_rgb.yaml"
VENV_DIR="${ROOT_DIR}/.venv_oe_py310"
HB_MAPPER_BIN="${VENV_DIR}/bin/hb_mapper"

if [[ ! -x "$HB_MAPPER_BIN" ]]; then
  echo "hb_mapper is not installed at: $HB_MAPPER_BIN"
  exit 1
fi

CFG="${1:-$NV12_CFG}"

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

echo "[1/2] Checking ONNX compatibility"
"$HB_MAPPER_BIN" checker --model-type onnx --model "$MODEL_PATH" --march bayes-e

echo "[2/2] Building quantized bin"
"$HB_MAPPER_BIN" makertbin --config "$CFG" --model-type onnx

echo "Done. Output is under the working_dir configured inside:"
echo "  $CFG"
