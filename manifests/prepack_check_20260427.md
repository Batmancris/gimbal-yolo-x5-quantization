# Prepack Check - 2026-04-27

Check time: `2026-04-27 16:47:19 +08:00`

## Size Summary

- Root: `E:\research\1\yolo\x5_quantization_assets`
- File count after adding this report: 352
- Total size after adding this report: 445.82 MiB
- Directory count: 28

## vehicle_yolov8n_x5_640 Integrity Summary

- `source_onnx/best_fixed.onnx`: present.
- `configs/x5_quant_nv12_fixed.yaml`: present.
- `calibration/calibration_rgb_uint8_nchw`: present.
- `hb_mapper_output/x5_quant_output`: present.
- `deployment/best_640x640_bayese_nv12.bin`: present.
- `debug_archive`: present.
- `model_card.md`: present.
- Standalone vehicle logs: no separately migrated log file found.

## bear_yolov8n_x5_640 Integrity Summary

- `source_onnx/bear_best.onnx`: present.
- `configs/x5_quant_bear_nv12.yaml`: present.
- `calibration/bear_calibration_images`: present.
- `calibration/calibration_bear_rgb_uint8_nchw`: present.
- `hb_mapper_output/x5_quant_output_bear`: present.
- `deployment/bear_yolov8n_x5_640_nv12.bin`: present.
- `logs/hb_mapper_checker_bear.log`: present.
- `logs/hb_mapper_makertbin_bear.log`: present.
- `model_card.md`: present.

## Calibration Count Summary

- Vehicle calibration binaries: 100 `.bin` files.
- Bear calibration images: 100 image files.
- Bear calibration binaries: 100 `.bin` files.

## Bin Candidate Summary

- Vehicle deployment residual bin: `models/vehicle_yolov8n_x5_640/deployment/best_640x640_bayese_nv12.bin` (4.50 MiB).
- Vehicle hb_mapper candidate bin: `models/vehicle_yolov8n_x5_640/hb_mapper_output/x5_quant_output/vehicle_yolov8n_x5_640_nv12.bin` (4.57 MiB).
- Vehicle historical debug candidate: `models/vehicle_yolov8n_x5_640/debug_archive/x5_quant_output_v123/vehicle_yolov8n_x5_640_nv12_v123.bin` (4.69 MiB).
- Bear deployment candidate: `models/bear_yolov8n_x5_640/deployment/bear_yolov8n_x5_640_nv12.bin` (4.82 MiB).

No `.bin` candidate was deleted during this check.

## .hbm Check

- `.hbm` files found: none.

## Environment / Cache Directory Check

No migrated environment or cache directory was found for these patterns:

- `.venv*`
- `.horizon`
- `open_explorer_x5*`
- `rdk_model_zoo*`
- `.cache`
- `.local`
- `.vscode-server`
- `__pycache__`

Note: `models/vehicle_yolov8n_x5_640/debug_archive/.hb_check_old` exists inside the vehicle debug archive and is retained as a historical debug artifact, not treated as an OpenExplorer installation or user cache directory.

## Manifest SHA256 Check

- `manifests/quant_artifact_manifest.csv`: present, 350 rows, 0 empty SHA256 values.
- `manifests/calibration_manifest.csv`: present, 300 rows, 0 empty SHA256 values.
- Both manifests include vehicle and bear assets.
- `recommended_for_baidu_backup` values are normalized to `yes`.
- `recommended_for_github` values are normalized to `yes/no`; real model files, `.bin` files, and calibration data are marked `no`.

## Manual Confirmation Items

- Vehicle final deployment `.bin` must be validated on RDK X5 or the matching runtime environment.
- Bear final deployment `.bin` should also be validated on board before production use.
- Confirm runtime input assumptions (`nv12`, 640x640) in the final deployment scripts.
- Confirm the archive can be restored and inspected after compression before uploading to Baidu Netdisk.

## Recommended Package Name

`gimbal-yolo-x5-quantization-assets-20260427.rar`
