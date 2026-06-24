---
title: MedGemma
layout: default
parent: Products
nav_order: 1
permalink: /products/medgemma/
---

# MedGemma on AWS — Deployment Guide

> Subscribe to **MedGemma** via AWS Marketplace, deploy it to Amazon SageMaker, and run
> medical-image inference — all from your existing AWS account.

MedGemma is a medical vision-language model packaged by **Tech42** and delivered as an
AWS Marketplace SageMaker model package. This guide walks you through deploying it as a
**real-time endpoint** or a **batch transform job**.

[← Back to Tech42 home]({{ '/' | relative_url }})

---

## Contents

1. [Prerequisites](#prerequisites)
2. [Subscribe in AWS Marketplace](#subscribe-in-aws-marketplace)
3. [Deploy the model](#deploy-the-model)
   - [Get the Model ARN](#1-get-the-model-arn-prerequisite)
   - [Real-time endpoint](#2a-deploy-a-real-time-endpoint)
   - [Batch transform job](#2b-deploy-a-batch-transform-job)
4. [Stack parameters reference](#stack-parameters-reference)
   - [Real-time endpoint parameters](#real-time-endpoint-parameters)
   - [Batch transform parameters](#batch-transform-parameters)
5. [Run inference (notebooks)](#run-inference-notebooks)
6. [Known issues](#known-issues)

---

## Prerequisites

- An AWS account with permission to use **AWS Marketplace**, **CloudFormation**, and **SageMaker**.
- **Service quota** for the instance type used by the endpoint:
  - Real-time inference → *SageMaker hosting* (endpoint usage) quota.
  - Batch transform → *SageMaker batch transform job* quota.
- The quota must exist **in the AWS Region where you deploy**. See [Known issues](#known-issues)
  if your quota is zero or insufficient.

---

## Subscribe in AWS Marketplace

1. Open the [AWS Marketplace](https://aws.amazon.com/marketplace).
2. Search for **"MedGemma"** and select the product offered by **Tech42**
   (top match: *MedGemma 1.5 4B*).

   ![AWS Marketplace search for "medgemma" — MedGemma 1.5 4B by Tech42 is the top match]({{ '/images/01_subscribe.png' | relative_url }})

3. On the listing page, click **View purchase options**.

   ![MedGemma 1.5 4B listing page with the View purchase options button]({{ '/images/02_subscribe.png' | relative_url }})

4. Review the **EULA**, pricing, and purchase details, then click **Subscribe**.

   ![Purchase details page showing the offer and the Subscribe button]({{ '/images/03_subscribe.png' | relative_url }})

5. Wait **1–2 minutes** for the subscription to validate in your account.

**Confirm the subscription:**

1. In the console, go to **AWS Marketplace → Manage Subscriptions → Active Subscriptions**.
2. Filter **Delivery method** by **"SageMaker Model"**.
3. Confirm **MedGemma** appears in your product list.

---

## Deploy the model

Deployment is three steps: **get the Model ARN → launch a CloudFormation stack → run a notebook.**

### 1. Get the Model ARN (prerequisite)

The Model package ARN changes with both the **Region** and the **product version**, so copy the
one that matches your target Region.

1. Go to **AWS Marketplace → Manage Subscriptions** and open your **MedGemma** subscription,
   then click **Configure** (top right).

   ![MedGemma subscription page with the Configure button highlighted]({{ '/images/04_fetch_arn.png' | relative_url }})

2. On the **Setup** page, set **Launch method** to **AWS CloudFormation**, then choose the
   **Version** and the **Region** you will deploy in.

3. In the **Model ARNs** panel on the right, copy the ARN for your chosen **Region** — you will
   paste it into the stack parameters below.

   ![Setup page with AWS CloudFormation selected and the Model ARNs panel on the right]({{ '/images/05_fetch_arn.png' | relative_url }})

{: .warning }
> This page is **only** for copying the Model ARN. Do **not** click **Launch CloudFormation
> template** (or **Download CloudFormation template**) here — those use the default AWS
> Marketplace stack. Instead, deploy with the **Tech42 CloudFormation templates** in
> [step 2a](#2a-deploy-a-real-time-endpoint) / [step 2b](#2b-deploy-a-batch-transform-job),
> which provision the full set of resources recommended for this implementation (autoscaling,
> CloudWatch dashboard, execution role, encryption/VPC options, and more).

### 2a. Deploy a real-time endpoint

Launch the real-time stack (or open it from the product's **Usage instructions** page):

| Deployment type | Launch |
|---|---|
| **Real-time inference** | [![Launch Stack](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home#/stacks/create/review?templateURL=https://tech42-medgemma-deployment-assets.s3.us-east-1.amazonaws.com/template-marketplace-realtime.json) |

Then:

1. Set a **Stack name**.
2. Fill the **Parameters** — paste the **Model ARN** from step 1 into **Marketplace Product ARN**.
   This is the only required field; every other parameter has a sensible default. See the
   [Real-time endpoint parameters](#real-time-endpoint-parameters) reference below.
3. Click **Create stack** and wait for `CREATE_COMPLETE`.

Template in this repo: [`cf/template-marketplace-realtime.json`]({{ '/cf/template-marketplace-realtime.json' | relative_url }})
(creates the SageMaker model, endpoint config, endpoint, and a CloudWatch dashboard).

### 2b. Deploy a batch transform job

| Deployment type | Launch |
|---|---|
| **Batch transform** | [![Launch Stack](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home#/stacks/create/review?templateURL=https://tech42-medgemma-deployment-assets.s3.us-east-1.amazonaws.com/template-marketplace-batch-transform.json) |

Same flow: set a stack name, paste the **Model ARN**, create the stack. Unlike the real-time
template, batch transform also requires a **SageMaker Execution Role ARN**, an **Input S3 URI**,
and an **Output S3 URI**. See the [Batch transform parameters](#batch-transform-parameters)
reference below.

Template in this repo: [`cf/template-marketplace-batch-transform.json`]({{ '/cf/template-marketplace-batch-transform.json' | relative_url }})
(creates the SageMaker model plus a managed S3 bucket for batch input/output).

---

## Stack parameters reference

When you launch a stack, CloudFormation prompts for the parameters below, grouped exactly as
they appear in the console. **Bold "Required"** fields have no default and must be supplied;
everything else can be left at its default for a standard deployment.

### Real-time endpoint parameters

**General Options**

| Parameter | Default | Notes |
|---|---|---|
| Marketplace Product ARN | **Required** | Model package ARN for your subscribed **version + Region**, copied from the Marketplace configuration page ([step 1](#1-get-the-model-arn-prerequisite)). |
| Endpoint Name | `medgemma-marketplace-endpoint` | Name of the SageMaker endpoint. 1–63 chars; letters, numbers, hyphens. |
| Marketplace Referrer URL | — | Optional link back to the Marketplace configuration page. |

**Size Options**

| Parameter | Default | Notes |
|---|---|---|
| Instance Type | `ml.g7e.2xlarge` | Allowed: `ml.g5.xlarge/2xlarge/4xlarge`, `ml.g6.xlarge/2xlarge/4xlarge`, `ml.g6e.xlarge/2xlarge/4xlarge`, `ml.g7e.2xlarge/4xlarge`. Drives cost and the quota you need. |
| Initial Instance Count | `1` | Instances launched with the endpoint (min 1). |

**Scaling Options**

| Parameter | Default | Notes |
|---|---|---|
| Enable Auto Scaling | `Yes` | `Yes`/`No`. Configures Application Auto Scaling on the variant. |
| Minimum Instance Count | `1` | Floor for autoscaling. |
| Maximum Instance Count | `4` | Ceiling for autoscaling. |
| Invocations Per Instance Target | `5` | Target invocations/instance that triggers scaling. |
| Scale-In Cooldown Seconds | `300` | Wait after a scale-in before the next. |
| Scale-Out Cooldown Seconds | `60` | Wait after a scale-out before the next. |

**Advanced Configuration**

| Parameter | Default | Notes |
|---|---|---|
| SageMaker Execution Role ARN | — | Leave blank and the stack **creates** a least-privilege role; set an ARN to reuse your own. |
| Production Variant Name | `AllTraffic` | Name of the endpoint production variant. |
| Model Data Download Timeout Seconds | `3600` | 60–3600. Max wait for model artifacts to download. |
| Container Startup Health Check Timeout Seconds | `1800` | 60–3600. Max wait for the container to pass health checks. |

**Security & Encryption**

| Parameter | Default | Notes |
|---|---|---|
| KMS Key ID | — | Key ID (UUID) or ARN to encrypt endpoint config + captured data. Blank = default SSE-S3. |
| VPC Subnet IDs | — | Comma-separated subnet IDs to run the model in a VPC. Blank = no VPC. |
| VPC Security Group IDs | — | Comma-separated SG IDs. **Required if** VPC Subnet IDs is set. |
| Enable Network Isolation | `Yes` | `Yes`/`No`. Blocks outbound network from the model container. |

**Storage & Monitoring**

| Parameter | Default | Notes |
|---|---|---|
| EBS Volume Size GB | `0` | `0` = SageMaker default for the instance; otherwise 1–16384. |
| Data Capture S3 URI | — | S3 URI to capture requests/responses for monitoring. Blank = disabled. |
| Data Capture Sampling % | `0` | 0–100. Used only when Data Capture S3 URI is set. |

### Batch transform parameters

**General Options**

| Parameter | Default | Notes |
|---|---|---|
| Marketplace Product ARN | **Required** | Model package ARN for your subscribed **version + Region** ([step 1](#1-get-the-model-arn-prerequisite)). |
| Batch Transform Job Name | `medgemma-marketplace-batch` | Must be unique in the account/Region. 1–63 chars. |
| Marketplace Referrer URL | — | Optional link back to the Marketplace configuration page. |

**Data Options**

| Parameter | Default | Notes |
|---|---|---|
| Input S3 URI | **Required** | S3 prefix or object holding the batch request JSON. |
| Output S3 URI | **Required** | S3 prefix where transform output is written. |
| Input Content Type | `application/json` | MIME type of the input records. |
| Output Accept MIME Type | `application/json` | Requested MIME type of the output. |

**Size Options**

| Parameter | Default | Notes |
|---|---|---|
| Instance Type | `ml.g5.2xlarge` | **The G5 family is not supported for batch transform** (CUDA/driver image incompatibility — see [Known issues](#known-issues)). Override the default with a newer supported GPU family. |
| Instance Count | `1` | Instances for the transform job (min 1). |

**Transform Options**

| Parameter | Default | Notes |
|---|---|---|
| Max Concurrent Transforms | `1` | Concurrent requests sent to each instance. |
| Max Payload Size MB | `6` | 1–100. Largest single record payload. |
| Batch Strategy | `SingleRecord` | `SingleRecord`/`MultiRecord`. |
| Input Split Type | `None` | `None`/`Line`/`RecordIO`/`TFRecord`. How input is split into records. |
| Input Compression Type | `None` | `None`/`Gzip`. |
| Output Assembly | `None` | `None`/`Line`. How output records are assembled. |
| S3 Data Type | `S3Prefix` | `S3Prefix`/`ManifestFile`/`EnhancedManifestFile`. |
| Container Environment (JSON) | — | Optional JSON of env vars, e.g. `{"MAX_BATCH_SIZE":"8"}`. |

**Advanced Configuration**

| Parameter | Default | Notes |
|---|---|---|
| SageMaker Execution Role ARN | **Required** | Valid IAM role ARN SageMaker assumes to run the job (unlike real-time, the batch template does **not** create one). |
| Batch Transform AMI Version | `al2-ami-sagemaker-batch-gpu-535` | Keep the default for the CUDA GPU image. |
| Data Processing Input Filter | — | Optional JSONPath to filter input before transform. |
| Data Processing Output Filter | — | Optional JSONPath to filter output after transform. |
| Data Processing Join Source | `None` | `None`/`Input`/`Output`. Join transform input with output. |
| Model Client Max Retries | `0` | 0–100. `0` = SageMaker default. |
| Model Client Timeout (ms) | `0` | `0` = SageMaker default; max 3600000. |

**Security & Encryption**

| Parameter | Default | Notes |
|---|---|---|
| KMS Key ID | — | Key ID (UUID) or ARN to encrypt job output. Blank = default SSE-S3. |
| VPC Subnet IDs | — | Comma-separated subnet IDs. Blank = no VPC. |
| VPC Security Group IDs | — | Comma-separated SG IDs. **Required if** VPC Subnet IDs is set. |
| Enable Network Isolation | `Yes` | `Yes`/`No`. |

---

## Run inference (notebooks)

Example notebooks live in the [`notebooks/`]({{ '/notebooks/' | relative_url }}) folder:

| Notebook | Purpose |
|---|---|
| [`realtime_endpoint.ipynb`]({{ '/notebooks/realtime_endpoint.ipynb' | relative_url }}) | Invoke the real-time endpoint with a medical image and read the response. |
| [`batch_transform.ipynb`]({{ '/notebooks/batch_transform.ipynb' | relative_url }}) | Upload a JSONL batch request, launch a batch transform job, and read the output. |

A sample input image is provided at `notebooks/inputs/chest_xray.png`.

---

## Known issues

| Symptom | Cause | Fix |
|---|---|---|
| Stack fails creating the endpoint | **Quota not available** — the account has **0** quota for the instance type. | Request a quota increase in **Service Quotas → Amazon SageMaker** for the endpoint instance type, then redeploy. |
| `ResourceLimitExceeded` during deploy | **Insufficient quota in the Region.** | Raise the quota in that Region, or deploy in a Region where you already have capacity. |
| Batch transform job fails to start or crashes on a **G5** instance | The MedGemma batch transform image ships the GPU driver / CUDA build required by the newer instance families. The **G5 family is not compatible** with that image. | Choose a newer supported GPU family for batch transform — **do not select `ml.g5.*`**. |

---

<sub>MedGemma is provided by Tech42 via AWS Marketplace. This guide is intended for AWS account
owners deploying the product into their own environment.</sub>
