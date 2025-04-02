# Multi-Model Example

This example demonstrates how to deploy multiple SageMaker models and endpoints concurrently using the [esm-partner Terraform Module](../README.md).

## Overview

In this configuration, we deploy two model endpoints simultaneously by specifying multiple entries in the `selected_models` map. Each entry represents a distinct deployment configuration. This approach allows you to run, compare, or scale multiple models as needed.

## What's Different

- **Multi-Model Deployments:**  
  Unlike the basic example, this configuration shows how to deploy more than one model concurrently. Here, we deploy:
  - A prototype model (using `ESMC-300M` with instance type `ml.g5.2xlarge`)
  - A performance model (using `ESMC-300M` with instance type `ml.g5.4xlarge`)

- **Configuration:**  
  The `selected_models` variable in this example includes multiple keys, each representing a model deployment. The module reads the model catalog from `models.yaml` and merges in any overrides specified in the map.


For full details on the module configuration, inputs, and outputs, please see the main [README](../README.md).
