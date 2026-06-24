---
layout: default
title: MedGemma
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
4. [Run inference (notebooks)](#run-inference-notebooks)
5. [Known issues](#known-issues)

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

On the product page:

**Configure → AWS CloudFormation → choose the version → choose the Region → scroll to
*Model ARNs* → copy the ARN for your Region.**

You will paste this value into the stack parameters below.

### 2a. Deploy a real-time endpoint

Launch the real-time stack (or open it from the product's **Usage instructions** page):

| Deployment type | Launch |
|---|---|
| **Real-time inference** | [![Launch Stack](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home#/stacks/create/review?templateURL=https://tech42-medgemma-deployment-assets.s3.us-east-1.amazonaws.com/template-marketplace-realtime.json) |

Then:

1. Set a **Stack name**.
2. Fill the **Parameters** — paste the **Model ARN** from step 1.
3. Click **Create stack** and wait for `CREATE_COMPLETE`.

Template in this repo: [`cf/template-marketplace-realtime.json`]({{ '/cf/template-marketplace-realtime.json' | relative_url }})
(creates the SageMaker model, endpoint config, endpoint, and a CloudWatch dashboard).

### 2b. Deploy a batch transform job

| Deployment type | Launch |
|---|---|
| **Batch transform** | [![Launch Stack](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home#/stacks/create/review?templateURL=https://tech42-medgemma-deployment-assets.s3.us-east-1.amazonaws.com/template-marketplace-batch-transform.json) |

Same flow: set a stack name, paste the **Model ARN**, create the stack.

Template in this repo: [`cf/template-marketplace-batch-transform.json`]({{ '/cf/template-marketplace-batch-transform.json' | relative_url }})
(creates the SageMaker model plus a managed S3 bucket for batch input/output).

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

---

<sub>MedGemma is provided by Tech42 via AWS Marketplace. This guide is intended for AWS account
owners deploying the product into their own environment.</sub>
