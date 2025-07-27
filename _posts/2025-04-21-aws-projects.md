---
layout: post
author: "Epy Blog"
title: "30+ Free-Tier AWS Micro-Projects to Master CLF-C02 Hands-On"
tags:
  - Cloud, AWS
usemathjax:     true
more_updates_card: true
excerpt_separator: <!--more-->
---

If you're preparing for the **AWS Certified Cloud Practitioner (CLF-C02)** exam and want to go beyond theory, these **micro-projects** are for you. Each project is designed to help you **practice a specific AWS service hands-on**, with clear objectives, and all projects fall **within the AWS Free Tier**.

<!--more-->


## ✅ Project 1 – Host a Static Website on Amazon S3
**Objective:**  
Learn how to use Amazon S3 to host a public-facing static HTML website with public access via a browser. This project introduces you to S3’s storage and static website capabilities, including bucket permissions, file upload, and endpoint access.

**AWS Services:**  
Amazon S3

**Free Tier Benefits:**  
- 5 GB standard storage  
- 1 GB data transfer out/month

**What You’ll Do:**  
- Create an S3 bucket with public access  
- Upload an `index.html` file  
- Enable static website hosting  
- Access your website via the public S3 website endpoint

**Bonus:**  
Try adding CSS, images, and folder structures to simulate a multi-page website.



## ✅ Project 2 – Create a Hello World Lambda Function
**Objective:**  
Deploy a serverless function using AWS Lambda that returns “Hello from Lambda”. This project introduces serverless computing and event-driven architecture using a simple function.

**AWS Services:**  
AWS Lambda

**Free Tier Benefits:**  
- 1M requests/month  
- 400,000 GB-seconds of compute time/month

**What You’ll Do:**  
- Create a Lambda function using Python or Node.js  
- Write a simple function to return a greeting  
- Test it from the AWS console  
- View execution logs in CloudWatch

**Bonus:**  
Return the current time or request metadata using environment variables or logging.



## ✅ Project 3 – Create a DynamoDB Table for a To-Do List
**Objective:**  
Create a NoSQL database using DynamoDB to store and retrieve to-do items. You’ll define a schema, add data entries, and use the AWS console or CLI to interact with the database.

**AWS Services:**  
Amazon DynamoDB

**Free Tier Benefits:**  
- 25 GB storage  
- 25 Write Capacity Units (WCU)  
- 25 Read Capacity Units (RCU)

**What You’ll Do:**  
- Create a `TodoList` table  
- Add items with `task_id`, `description`, and `status`  
- Retrieve entries via console or CLI  
- Understand partition keys and item structure

**Bonus:**  
Set up a Lambda function to log new tasks automatically.


## ✅ Project 4 – Create a Budget and Billing Alert
**Objective:**  
Use AWS Budgets to track your Free Tier usage and avoid surprise charges. This project helps you stay cost-aware while experimenting on AWS.

**AWS Services:**  
AWS Budgets, AWS Billing, Amazon SNS

**Free Tier Benefits:**  
- Always free for up to two budget alerts

**What You’ll Do:**  
- Create a budget (e.g., ₹50 or $1)  
- Set up SNS notifications to send budget alerts to your email  
- Monitor service usage from the AWS Billing Dashboard

**Bonus:**  
Configure service-level budgets (e.g., only EC2 or S3 costs).



## ✅ Project 5 – Build a Serverless Contact Form
**Objective:**  
Create a simple HTML contact form that uses API Gateway to trigger a Lambda function, which then sends an email using Amazon SES. This project walks you through a full serverless contact submission pipeline.

**AWS Services:**  
Amazon API Gateway, AWS Lambda, Amazon SES

**Free Tier Benefits:**  
- 1M API Gateway calls/month  
- 1M Lambda requests/month  
- 62,000 outbound emails/month (in sandbox)

**What You’ll Do:**  
- Write an HTML form  
- Configure an API Gateway endpoint (POST method)  
- Create a Lambda function to read form data and call SES  
- Send the email and verify delivery

**Bonus:**  
Store submissions in DynamoDB for future reference.



## ✅ Project 6 – Send Email Notifications with Amazon SNS
**Objective:**  
Use Amazon SNS to send push-style notifications via email. This project introduces publish-subscribe patterns and demonstrates how decoupled messaging works in AWS.

**AWS Services:**  
Amazon Simple Notification Service (SNS)

**Free Tier Benefits:**  
- 1M publish requests/month  
- 1,000 email deliveries/month

**What You’ll Do:**  
- Create a topic in SNS  
- Subscribe your email address to the topic  
- Publish a test message using the AWS Console

**Bonus:**  
Use Lambda or CloudWatch Events to publish automated messages.



## ✅ Project 7 – Simulate a Message Queue with Amazon SQS
**Objective:**  
Get hands-on with message queuing by creating a queue, sending messages, and retrieving them. This is foundational for understanding distributed systems and asynchronous processing.

**AWS Services:**  
Amazon Simple Queue Service (SQS)

**Free Tier Benefits:**  
- 1M requests/month

**What You’ll Do:**  
- Create a standard SQS queue  
- Send a few test messages  
- Retrieve and delete messages using the AWS Console  
- Explore visibility timeout settings

**Bonus:**  
Trigger a Lambda function when a new message arrives.



## ✅ Project 8 – Schedule a Cron Job with Amazon CloudWatch
**Objective:**  
Use CloudWatch Events to schedule automated tasks in AWS. In this case, you'll trigger a Lambda function every 5 minutes — perfect for health checks, periodic cleanups, or reports.

**AWS Services:**  
Amazon CloudWatch, AWS Lambda

**Free Tier Benefits:**  
- 1M metrics/month  
- 10 custom metrics and alarms/month  
- 1M Lambda requests/month

**What You’ll Do:**  
- Set up a CloudWatch Event rule using `rate(5 minutes)`  
- Create a Lambda that logs timestamps  
- Review logs in CloudWatch to confirm periodic execution

**Bonus:**  
Use this to clean up unused S3 files or keep-alive EC2 checks.



## ✅ Project 9 – Launch and SSH into a Free EC2 Instance
**Objective:**  
Understand virtual machine provisioning in the cloud by launching a free-tier EC2 instance. You’ll connect via SSH and explore the instance like a Linux server.

**AWS Services:**  
Amazon EC2

**Free Tier Benefits:**  
- 750 hours/month of t2.micro or t3.micro instances

**What You’ll Do:**  
- Launch a new EC2 instance (Ubuntu preferred)  
- Create or use an existing key pair  
- Configure security group to allow SSH (port 22)  
- Connect via terminal (or PuTTY on Windows)

**Bonus:**  
Install Apache or NGINX and serve a simple HTML page from `/var/www/html`.



## ✅ Project 10 – Deploy an S3 Bucket Using CloudFormation
**Objective:**  
Use a YAML-based CloudFormation template to provision an S3 bucket automatically. This is your first taste of Infrastructure as Code (IaC).

**AWS Services:**  
AWS CloudFormation, Amazon S3

**Free Tier Benefits:**  
- Always free for usage

**What You’ll Do:**  
- Write a simple YAML template to define an S3 bucket  
- Deploy it as a CloudFormation stack  
- Check the Resources and Events tab for status  
- Delete the stack to clean up

**Bonus:**  
Add metadata tags, versioning, or bucket policy into your template.


## ✅ Project 11 – Create a Least-Privilege IAM User
**Objective:**  
Understand identity and access management by creating an IAM user with minimal permissions. This project helps you grasp how roles, users, and policies work in AWS.

**AWS Services:**  
AWS Identity and Access Management (IAM)

**Free Tier Benefits:**  
- Always free

**What You’ll Do:**  
- Create a new IAM user  
- Attach an S3 read-only policy  
- Log in as the IAM user and verify access  
- Test what resources are accessible or restricted

**Bonus:**  
Use IAM Policy Simulator to preview access behavior.



## ✅ Project 12 – Enable MFA for an IAM User
**Objective:**  
Improve account security by enabling Multi-Factor Authentication (MFA) for an IAM user.

**AWS Services:**  
AWS IAM

**Free Tier Benefits:**  
- Always free

**What You’ll Do:**  
- Enable MFA on the IAM user account  
- Use an authenticator app (like Google Authenticator)  
- Login using username + password + OTP code

**Bonus:**  
Create a policy that denies all actions unless MFA is enabled.



## ✅ Project 13 – Encrypt and Decrypt Data Using AWS KMS
**Objective:**  
Use AWS Key Management Service (KMS) to create a CMK (Customer Master Key) and perform basic encryption and decryption.

**AWS Services:**  
AWS KMS

**Free Tier Benefits:**  
- 20,000 free requests/month

**What You’ll Do:**  
- Create a CMK in your region  
- Use the console or CLI to encrypt a sample string  
- Decrypt the ciphertext back into plaintext

**Bonus:**  
Enable automatic rotation for your CMK.



## ✅ Project 14 – Store a Secret in AWS Secrets Manager
**Objective:**  
Securely store a database password or API key using AWS Secrets Manager and retrieve it programmatically.

**AWS Services:**  
AWS Secrets Manager

**Free Tier Benefits:**  
- 30 days free per secret

**What You’ll Do:**  
- Create a secret (e.g., DB credentials)  
- Retrieve the secret using AWS Console or SDK  
- Use tags and rotation settings

**Bonus:**  
Use Lambda to retrieve the secret securely at runtime.



## ✅ Project 15 – Query Data in S3 Using Amazon Athena
**Objective:**  
Use Athena to run SQL queries directly on CSV or JSON files stored in S3 without setting up a database.

**AWS Services:**  
Amazon Athena, Amazon S3

**Free Tier Benefits:**  
- 1 TB queries/month (Athena)

**What You’ll Do:**  
- Upload a sample CSV to S3  
- Create a table in Athena using the Glue Data Catalog  
- Write and run SQL queries on the dataset

**Bonus:**  
Visualize your query results using Amazon QuickSight.



## ✅ Project 16 – Create a Dashboard in Amazon QuickSight
**Objective:**  
Visualize data stored in S3 or queried via Athena by building a report or dashboard in QuickSight.

**AWS Services:**  
Amazon QuickSight

**Free Tier Benefits:**  
- Free for 1 user (Standard Edition trial)

**What You’ll Do:**  
- Connect to an S3 dataset or Athena table  
- Create visualizations (bar chart, pie chart, etc.)  
- Publish and share your dashboard

**Bonus:**  
Try adding calculated fields or filters.



## ✅ Project 17 – Detect Sentiment Using Amazon Comprehend
**Objective:**  
Use AWS Comprehend to perform basic sentiment analysis and named entity recognition on a block of text.

**AWS Services:**  
Amazon Comprehend

**Free Tier Benefits:**  
- 50K units/month for entity/sentiment detection

**What You’ll Do:**  
- Input a few customer reviews or sentences  
- Run them through Comprehend  
- Review extracted entities and sentiment scores

**Bonus:**  
Combine with Transcribe or Textract for pipeline use.



## ✅ Project 18 – Build a Chatbot with Amazon Lex
**Objective:**  
Create a basic conversational bot that can handle predefined user intents like greeting or asking for help.

**AWS Services:**  
Amazon Lex

**Free Tier Benefits:**  
- 10,000 text requests/month

**What You’ll Do:**  
- Define a bot with sample utterances and responses  
- Test it using the AWS Lex console  
- Integrate with a frontend (optional)

**Bonus:**  
Use Lambda to dynamically generate responses.



## ✅ Project 19 – Convert Text to Speech Using Amazon Polly
**Objective:**  
Use Amazon Polly to generate an MP3 audio file from text input.

**AWS Services:**  
Amazon Polly

**Free Tier Benefits:**  
- 5 million characters/month

**What You’ll Do:**  
- Input text into Polly using the console  
- Choose a voice and language  
- Download and play the resulting audio file

**Bonus:**  
Serve generated audio from an S3-hosted page.



## ✅ Project 20 – Translate Text with Amazon Translate
**Objective:**  
Use Amazon Translate to convert text between different languages and integrate it into multilingual applications.

**AWS Services:**  
Amazon Translate

**Free Tier Benefits:**  
- 2 million characters/month

**What You’ll Do:**  
- Input sentences and detect language  
- Translate English to other languages  
- Analyze confidence scores and alternate translations

**Bonus:**  
Build a simple multilingual chatbot using Lex + Translate.


## ✅ Project 21 – Track Resource Changes with AWS Config
**Objective:**  
Enable AWS Config to track configuration changes in your resources and gain visibility into compliance.

**AWS Services:**  
AWS Config

**Free Tier Benefits:**  
- 10,000 configuration items/month

**What You’ll Do:**  
- Enable AWS Config in your region  
- Choose to record all resources  
- Launch or modify an EC2 instance or S3 bucket  
- View recorded changes in the AWS Config console

**Bonus:**  
Enable compliance rules like “S3 buckets should not be public.”



## ✅ Project 22 – Log All API Activity with AWS CloudTrail
**Objective:**  
Set up CloudTrail to record all API activity across your AWS account. This helps in audits and troubleshooting.

**AWS Services:**  
AWS CloudTrail

**Free Tier Benefits:**  
- Management events: 90 days free  
- 1 trail per account always free

**What You’ll Do:**  
- Enable CloudTrail  
- Launch and delete a test EC2 or S3 resource  
- Go to CloudTrail Event History to review API activity

**Bonus:**  
Send CloudTrail logs to S3 for long-term storage.



## ✅ Project 23 – Set Up a Private Git Repository with AWS CodeCommit
**Objective:**  
Host your own Git repositories using AWS CodeCommit and integrate them with CodeBuild or CodePipeline.

**AWS Services:**  
AWS CodeCommit

**Free Tier Benefits:**  
- 5 users, 50 GB/month

**What You’ll Do:**  
- Create a CodeCommit repository  
- Clone it to your local machine  
- Add, commit, and push some files  
- View repo activity in the console

**Bonus:**  
Trigger builds or deployments via commits.



## ✅ Project 24 – Build and Test Code with AWS CodeBuild
**Objective:**  
Use CodeBuild to compile source code and run unit tests automatically when triggered.

**AWS Services:**  
AWS CodeBuild

**Free Tier Benefits:**  
- 100 build minutes/month

**What You’ll Do:**  
- Connect a CodeCommit repo  
- Define a buildspec.yml file  
- Create and run a build project  
- View logs and artifacts

**Bonus:**  
Run a simple test script in Python or Node.js.



## ✅ Project 25 – Automate Deployments with AWS CodePipeline
**Objective:**  
Set up a CI/CD pipeline that automatically deploys your application every time you push new code.

**AWS Services:**  
AWS CodePipeline, CodeCommit, CodeBuild

**Free Tier Benefits:**  
- 1 active pipeline/month

**What You’ll Do:**  
- Connect your CodeCommit repo  
- Add CodeBuild as a stage  
- Push new commits and see the pipeline trigger

**Bonus:**  
Add a manual approval step before deployment.



## ✅ Project 26 – Extract Text from Documents Using Amazon Textract
**Objective:**  
Extract structured text data (like tables and form fields) from scanned documents.

**AWS Services:**  
Amazon Textract

**Free Tier Benefits:**  
- 1,000 pages/month for 3 months

**What You’ll Do:**  
- Upload a scanned PDF to the console  
- Run Textract to extract key-value pairs  
- Review structured output

**Bonus:**  
Use the API to process documents programmatically.



## ✅ Project 27 – Create a Knowledge Search Engine with Amazon Kendra
**Objective:**  
Build an intelligent search experience by indexing PDFs, docs, or text and retrieving answers to natural language queries.

**AWS Services:**  
Amazon Kendra

**Free Tier Benefits:**  
- Free developer edition (up to 750 hours/month)

**What You’ll Do:**  
- Create a Kendra index  
- Upload sample FAQs or help docs  
- Run a search query to get ranked results

**Bonus:**  
Integrate Kendra results into a Lex chatbot.



## ✅ Project 28 – Secure Your Web App with AWS WAF
**Objective:**  
Protect your website against common web exploits using AWS Web Application Firewall.

**AWS Services:**  
AWS WAF

**Free Tier Benefits:**  
- Up to 10 web ACLs and rules per month

**What You’ll Do:**  
- Attach WAF to an existing CloudFront distribution  
- Add a rule to block IPs or common attacks  
- Test your WAF by accessing from blocked IPs

**Bonus:**  
Enable AWS Managed Rules for OWASP protection.



## ✅ Project 29 – Enable DDoS Protection Using AWS Shield
**Objective:**  
Understand AWS Shield Standard and how it automatically protects public AWS endpoints against DDoS attacks.

**AWS Services:**  
AWS Shield (Standard)

**Free Tier Benefits:**  
- Always free and automatically enabled

**What You’ll Do:**  
- Deploy a public S3 website or CloudFront endpoint  
- Go to AWS Shield Dashboard  
- View real-time protection metrics

**Bonus:**  
Pair Shield with WAF for layered security.



## ✅ Project 30 – Register and Configure a Domain with Route 53
**Objective:**  
Buy and configure a custom domain name for your app or website using Route 53.

**AWS Services:**  
Amazon Route 53

**Free Tier Benefits:**  
- No free domain, but hosted zone management is low-cost

**What You’ll Do:**  
- Register a domain (costs ~$12/year)  
- Create a public hosted zone  
- Add A/AAAA/CNAME records for your app  
- Test domain resolution

**Bonus:**  
Use latency-based routing or weighted routing policies.


## ✅ Bonus Project 31 – Simulate a Server Migration with AWS Application Migration Service
**Objective:**  
Understand how to simulate the lift-and-shift migration of an on-premises server to AWS using the Application Migration Service (MGN).

**AWS Services:**  
AWS Application Migration Service

**Free Tier Benefits:**  
- 2,160 hours/month for 2 months for migration instances

**What You’ll Do:**  
- Set up the MGN agent on a simulated source (like a local VM or lightweight EC2)  
- Configure replication settings  
- Launch a test instance in AWS  
- Validate the cutover process

**Bonus:**  
Test rollback and failback procedures to gain real-world readiness.



# ✅ Wrapping Up: Your Practical Path to CLF-C02

These 31+ micro-projects are designed to help you gain **real, hands-on experience** across nearly every service covered in the **AWS Cloud Practitioner (CLF-C02)** syllabus. 
Whether you're a beginner or brushing up your cloud fundamentals, these projects will give you confidence beyond the whiteboard.

✅ **All projects stay within the AWS Free Tier**  
✅ **Each project focuses on a single concept or service**  
✅ **No prior cloud experience required**

---

**Pro Tip:**  
Track your AWS Free Tier usage from the [Billing Dashboard](https://console.aws.amazon.com/billing/home#/dashboard) and set up alerts using **AWS Budgets**.

If you found this helpful, consider turning these micro-projects into portfolio entries or GitHub demos — they make great conversation starters in interviews!

Happy building ☁️🚀
Team Elastropy