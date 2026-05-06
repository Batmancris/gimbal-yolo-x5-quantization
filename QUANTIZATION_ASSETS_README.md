# X5 Quantization Assets

This directory is the local archive for RDK X5 / Horizon OpenExplorer quantization assets.

It contains the quantization inputs, configs, outputs, deployment candidates, logs, manifests, and model cards for:

- `vehicle_yolov8n_x5_640`
- `bear_yolov8n_x5_640`

## Scope

- Included: source ONNX files, Horizon YAML configs, calibration samples, preprocessed calibration `.bin` tensors, `hb_mapper_output`, deployment `.bin` candidates, logs, debug archive files, and SHA256 manifests.
- Not included: training dataset bodies, OpenExplorer installation directories, virtual environments, Horizon caches, RDK model zoo source trees, VS Code server files, or user cache directories.
- This directory should not be committed to GitHub.
- Future GitHub repositories should keep only scripts, template configs, and documentation.
- The intended backup flow is to compress this directory locally and upload the package to Baidu Netdisk.

## Before Use

No final deployment `.bin` should be treated as production-ready until it is validated on an RDK X5 board or the matching Horizon toolchain/runtime environment.

Recommended package name:

`gimbal-yolo-x5-quantization-assets-20260427.rar`
