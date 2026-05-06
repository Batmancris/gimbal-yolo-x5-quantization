# Gimbal YOLO X5 量化归档

RDK X5 (Horizon OpenExplorer) 平台的 YOLO 模型量化产物归档。包含两个云台目标检测模型的完整量化资产。

## 目录结构

```
├── models/
│   ├── vehicle_yolov8n_x5_640/        # 车辆检测模型
│   │   ├── source/                     #   原始 ONNX 模型
│   │   ├── config/                     #   hb_mapper 量化配置 (YAML)
│   │   ├── calibration/                #   校准数据 (100 个 .bin)
│   │   ├── output/                     #   hb_mapper 中间产物
│   │   └── deployment/                 #   最终部署用 .bin
│   └── bear_yolov8n_x5_640/           # 熊检测模型
│       ├── source/                     #   原始 ONNX 模型
│       ├── config/                     #   hb_mapper 量化配置
│       ├── calibration/                #   校准图片 (100 张) + .bin
│       ├── output/                     #   中间 ONNX + 子图可视化
│       ├── deployment/                 #   最终部署用 .bin
│       └── logs/                       #   mapper 运行日志
├── scripts/                            # 量化辅助脚本
├── manifests/                          # SHA256 文件校验清单
└── .venv_oe_py310/ + .horizon/ddk/    # 量化环境 (gitignored)
```

## 模型说明

| 模型 | 任务 | 输入尺寸 | 输入格式 | 部署文件 |
|------|------|----------|----------|----------|
| vehicle_yolov8n_x5_640 | 车辆检测 | 1x3x640x640 | NV12 | `deployment/best_640x640_bayese_nv12.bin` |
| bear_yolov8n_x5_640 | 熊检测 | 1x3x640x640 | NV12 | `deployment/bear_yolov8n_x5_640_nv12.bin` |

两个模型均基于 YOLOv8n，使用 Horizon `hb_mapper` 工具链从 FP32 ONNX 量化为 X5 平台可用的 `.bin` 格式。

## 重新运行量化

```bash
# 激活量化环境
source .venv_oe_py310/bin/activate

# 量化车辆模型
bash scripts/run_x5_quant.sh models/vehicle_yolov8n_x5_640/config/x5_quant_best_nv12.yaml

# 量化熊模型
bash scripts/run_x5_quant.sh models/bear_yolov8n_x5_640/config/x5_quant_bear_nv12.yaml
```

## 注意事项

- 部署用 `.bin` 文件需要在 RDK X5 开发板上验证后才能用于生产
- 校准数据 (calibration/) 体量较大，已通过 `.gitignore` 排除
- 环境依赖：`.venv_oe_py310/` (Python 3.10 + hb_mapper)、`.horizon/ddk/` (Horizon DDK)
- 量化配置中的路径为绝对路径，迁移目录后需要重新修改 YAML 中的 `onnx_model`、`cal_data_dir`、`working_dir`
