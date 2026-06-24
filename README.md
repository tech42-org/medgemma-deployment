# medgemma-deployment

Deployment assets and documentation for **MedGemma on AWS** — a medical vision-language
model packaged by [Tech42 Consulting](https://tech42consulting.com) and delivered through
AWS Marketplace as an Amazon SageMaker model package.

## 📖 Documentation site

**→ https://tech42-org.github.io/medgemma-deployment/**

- **Home:** Tech42 Consulting overview + product catalog
- **MedGemma guide:** https://tech42-org.github.io/medgemma-deployment/products/medgemma/
  (subscribe → get Model ARN → deploy via CloudFormation → run inference)

The site is built with GitHub Pages (Jekyll + minima) from the markdown in this repo.

## Repository layout

```text
.
├── index.md                 Docs-site home (Tech42 overview + products)
├── products/
│   └── medgemma.md          MedGemma deployment guide (the product page)
├── cf/                       CloudFormation templates
│   ├── template-marketplace-realtime.json        Real-time endpoint + CloudWatch dashboard
│   └── template-marketplace-batch-transform.json Batch transform + managed S3 bucket
├── notebooks/                Example inference notebooks
│   ├── realtime_endpoint.ipynb
│   ├── batch_transform.ipynb
│   └── inputs/chest_xray.png Sample medical image
├── images/                   Screenshots used by the docs pages
└── _config.yml               Jekyll / GitHub Pages configuration
```

## Quick deploy

| Deployment type | Launch |
|---|---|
| **Real-time inference** | [![Launch Stack](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home#/stacks/create/review?templateURL=https://tech42-medgemma-deployment-assets.s3.us-east-1.amazonaws.com/template-marketplace-realtime.json) |
| **Batch transform** | [![Launch Stack](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home#/stacks/create/review?templateURL=https://tech42-medgemma-deployment-assets.s3.us-east-1.amazonaws.com/template-marketplace-batch-transform.json) |

See the [full MedGemma guide](https://tech42-org.github.io/medgemma-deployment/products/medgemma/)
for prerequisites (SageMaker quota), the Model ARN step, and known issues.
