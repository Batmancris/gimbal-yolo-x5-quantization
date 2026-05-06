#!/usr/bin/env python3

import argparse
import sys

import onnx
from onnx import helper, numpy_helper
import numpy as np


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Rewrite Split nodes that use a second split input into opset-11 attributes."
    )
    parser.add_argument("--input", default="/home/demo/tianbot_ws/best.onnx")
    parser.add_argument("--output", default="/home/demo/tianbot_ws/best_fixed.onnx")
    args = parser.parse_args()

    model = onnx.load(args.input)
    initializers = {item.name: numpy_helper.to_array(item) for item in model.graph.initializer}

    fixed = 0
    resize_fixed = 0
    reshape_fixed = 0
    for node in model.graph.node:
        if node.op_type != "Split" or len(node.input) != 2:
            continue

        data_input = node.input[0]
        split_input = node.input[1]
        if split_input not in initializers:
            continue

        split_values = [int(v) for v in initializers[split_input].tolist()]
        kept_attrs = [attr for attr in node.attribute if attr.name != "split"]
        kept_attrs.append(helper.make_attribute("split", split_values))

        del node.input[:]
        node.input.extend([data_input])
        del node.attribute[:]
        node.attribute.extend(kept_attrs)
        fixed += 1

    roi_name = "_hb_empty_roi"
    has_roi_initializer = any(item.name == roi_name for item in model.graph.initializer)
    if not has_roi_initializer:
        model.graph.initializer.append(
            numpy_helper.from_array(np.array([], dtype=np.float32), name=roi_name)
        )

    for node in model.graph.node:
        if node.op_type != "Resize":
            continue
        if len(node.input) >= 2 and node.input[1] == "":
            node.input[1] = roi_name
            resize_fixed += 1

    for node in model.graph.node:
        if node.op_type != "Reshape":
            continue
        original_len = len(node.attribute)
        kept_attrs = [attr for attr in node.attribute if attr.name != "allowzero"]
        if len(kept_attrs) != original_len:
            del node.attribute[:]
            node.attribute.extend(kept_attrs)
            reshape_fixed += 1

    if fixed == 0:
        print("No Split nodes needed rewriting.")
        return 1

    # Remove the now-unused split initializers when possible.
    used_inputs = {name for node in model.graph.node for name in node.input}
    kept_initializers = [item for item in model.graph.initializer if item.name in used_inputs]
    del model.graph.initializer[:]
    model.graph.initializer.extend(kept_initializers)

    onnx.save(model, args.output)
    print(f"Rewrote {fixed} Split nodes.")
    print(f"Rewrote {resize_fixed} Resize nodes.")
    print(f"Rewrote {reshape_fixed} Reshape nodes.")
    print(f"Saved fixed model to: {args.output}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
