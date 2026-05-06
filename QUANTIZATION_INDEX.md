# Quantization Index

This directory contains RDK X5 / Horizon OpenExplorer quantization assets for gimbal YOLO deployment.

## Directory Structure

```
tianbot_ws/
├── models/
│   ├── vehicle_yolov8n_x5_640/    # Vehicle detection model
│   │   ├── source/                 # best.onnx
│   │   ├── config/                 # x5_quant YAML configs
│   │   ├── calibration/            # calibration_rgb_uint8_nchw/ (100 bins)
│   │   ├── output/                 # hb_mapper intermediates
│   │   └── deployment/             # best_640x640_bayese_nv12.bin
│   └── bear_yolov8n_x5_640/       # Bear detection model
│       ├── source/                 # bear_best.onnx
│       ├── config/                 # x5_quant_bear_nv12.yaml
│       ├── calibration/            # bear_calibration_images/ + calibration_bear_rgb_uint8_nchw/
│       ├── output/                 # hb_mapper intermediates + subgraph HTML/JSON
│       ├── deployment/             # bear_yolov8n_x5_640_nv12.bin
│       └── logs/                   # hb_mapper checker/makertbin logs
├── scripts/                        # run_x5_quant.sh, fix_split_for_opset11.py
├── manifests/                      # SHA256 manifests and prepack reports
├── .venv_oe_py310/                 # Python venv (hb_mapper + deps)
├── .horizon/ddk/                   # Horizon DDK runtime
└── open_explorer_x5/               # OpenExplorer SDK (296 MB)
```

## vehicle_yolov8n_x5_640

- Task: vehicle detection YOLOv8n model.
- Target platform: RDK X5 / Horizon OpenExplorer.
- Input size: `1x3x640x640`.
- Runtime input format: `nv12`, based on `config/x5_quant_nv12_fixed.yaml`.
- Source ONNX: `source/best.onnx`.
- Config YAML: `config/x5_quant_best_nv12.yaml` (primary), `x5_quant_best_nv12_adapt.yaml` (adapted), `x5_quant_best_rgb.yaml` (RGB variant), `x5_quant_nv12_fixed.yaml` (fixed opset).
- Calibration data: `calibration/calibration_rgb_uint8_nchw` with 100 RGB uint8 NCHW `.bin` tensors.
- hb_mapper output: `output/vehicle_yolov8n_x5_640_nv12.bin` + `quant_info.json`.
- Deployment bin: `deployment/best_640x640_bayese_nv12.bin`.
- Final deployment status: needs manual board-side validation before release.

## bear_yolov8n_x5_640

- Task: bear detection YOLOv8n model.
- Target platform: RDK X5 / Horizon OpenExplorer.
- Input size: `1x3x640x640`.
- Runtime input format: `nv12`, based on `config/x5_quant_bear_nv12.yaml`.
- Source ONNX: `source/bear_best.onnx`.
- Config YAML: `config/x5_quant_bear_nv12.yaml`.
- Calibration images: `calibration/bear_calibration_images` with 100 images.
- Calibration binaries: `calibration/calibration_bear_rgb_uint8_nchw` with 100 RGB uint8 NCHW `.bin` tensors.
- hb_mapper output: `output/` (calibrated/optimized/quantized ONNX + subgraph HTML/JSON).
- Deployment bin: `deployment/bear_yolov8n_x5_640_nv12.bin`.
- Logs: `logs/hb_mapper_checker_bear.log`, `logs/hb_mapper_makertbin_bear.log`.
- Final deployment status: should be validated on board before production use.

## Asset Notes

- Source ONNX files are the quantization inputs and should be retained.
- Config YAML files are the Horizon `hb_mapper` configuration records used for each model.
- Calibration data is heavyweight and excluded from git via `.gitignore`.
- `output/` preserves mapper-generated intermediates for audit; `.onnx` files excluded from git.
- `deployment/` contains selected `.bin` candidates for board testing.
- No `.hbm` file was found in the current archive.

## Environment

- Python venv: `.venv_oe_py310/` (hb_mapper + deps).
- DDK: `.horizon/ddk/` (Horizon DDK runtime).
- SDK: `open_explorer_x5/` (296 MB, can re-download).
- Quantization script: `scripts/run_x5_quant.sh`.
