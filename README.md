# ⏰ EC2 Work Hours Scheduler with AWS Lambda & EventBridge Scheduler

![Terraform](https://img.shields.io/badge/Terraform-1.x-7B42BC?logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-Lambda%20%26%20EC2-FF9900?logo=amazonaws&logoColor=white)
![AWS Lambda](https://img.shields.io/badge/AWS-Lambda-FF9900?logo=awslambda&logoColor=white)
![EventBridge](https://img.shields.io/badge/AWS-EventBridge%20Scheduler-FF9900?logo=amazonaws&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.x-3776AB?logo=python&logoColor=white)

## 📖 Overview

This project demonstrates an **automated EC2 work-hours scheduling system** built using AWS services and provisioned with **Terraform**.

The system automatically manages selected EC2 instances based on a predefined work schedule:

- 🟢 **Starts EC2 instances at 8:00 AM**
- 🔴 **Stops EC2 instances at 7:00 PM**
- 📅 Runs from **Monday to Friday**
- 🏷️ Only manages EC2 instances with the `Schedule=enabled` tag

Instead of manually starting and stopping EC2 instances every day, **Amazon EventBridge Scheduler** invokes an **AWS Lambda function** at the configured times. The Lambda function finds EC2 instances with the required tag and performs the requested action.

The same Lambda function handles both **start** and **stop** operations. EventBridge Scheduler sends either `"start"` or `"stop"` as input to determine which action the Lambda function should perform.

# 📸 Screenshots
<img width="1895" height="761" alt="ss3" src="https://github.com/user-attachments/assets/946644da-33c6-4a02-b470-b44df426e12a" />
<img width="1898" height="767" alt="ss2" src="https://github.com/user-attachments/assets/8093c066-978f-415f-b226-c1ba6351f425" />
<img width="1900" height="763" alt="ss1" src="https://github.com/user-attachments/assets/435c1b54-b747-4123-8722-9774d6e4d75e" />
<img width="1918" height="755" alt="ss4" src="https://github.com/user-attachments/assets/d9489c70-79d6-4618-b2da-84bdd9e9ac81" />


## 🎯 Key Features

- ✅ **Automated EC2 Start/Stop** – Automatically manages EC2 instances during work hours
- ⏰ **Scheduled Automation** – Separate schedules for starting and stopping instances
- 🏷️ **Tag-Based Instance Selection** – Only instances with `Schedule=enabled` are managed
- 🔐 **IAM Permissions** – Lambda receives permissions to describe, start, and stop EC2 instances
- 🔄 **Single Lambda Function** – One function handles both start and stop operations
- 🌏 **Time Zone Support** – Uses `Asia/Colombo`
- 📊 **CloudWatch Logging** – Lambda execution activity is logged
- 🏗️ **Infrastructure as Code** – AWS infrastructure is provisioned using Terraform
- 🛡️ **Controlled Lambda Invocation** – EventBridge Scheduler is explicitly allowed to invoke Lambda

## ⏰ Schedule Configuration

| Schedule | Time | Days | Time Zone | Lambda Input |
|:---|:---|:---|:---|:---|
| 🟢 EC2 Start | 8:00 AM | Monday–Friday | `Asia/Colombo` | `{"action":"start"}` |
| 🔴 EC2 Stop | 7:00 PM | Monday–Friday | `Asia/Colombo` | `{"action":"stop"}` |

### 🟢 Start Schedule

```text
cron(0 8 ? * MON-FRI *)
```

### 🔴 Stop Schedule

```text
cron(0 19 ? * MON-FRI *)
```

## 🧩 Infrastructure Components

| Component | Description | Purpose |
|:---|:---|:---|
| **Amazon EC2** | Virtual servers | Instances managed by the scheduler |
| **Security Group** | Virtual firewall | Controls EC2 network traffic |
| **AWS Lambda** | Serverless compute | Contains the EC2 start/stop logic |
| **Amazon EventBridge Scheduler** | Scheduling service | Invokes Lambda at configured times |
| **IAM Policy** | Permission definition | Defines what AWS actions are allowed |
| **IAM Role** | AWS service identity | Provides permissions to AWS services |
| **CloudWatch Logs** | Monitoring service | Stores Lambda execution logs |
| **Terraform** | Infrastructure as Code | Creates and manages AWS resources |
| **Archive Provider** | Terraform provider | Packages the Python Lambda code into a ZIP file |

# 🔐 IAM Configuration

This project uses separate IAM roles and policies for the Lambda function and EventBridge Scheduler.

## 1️⃣ Lambda Execution Role

The Lambda execution role is assumed by:

```text
lambda.amazonaws.com
```

The Lambda function requires permissions to:

```text
ec2:DescribeInstances
ec2:StartInstances
ec2:StopInstances
```

The Lambda execution role also requires CloudWatch logging permissions so that the function can write logs.

### Lambda Permission Flow

```text
Lambda Function
      │
      │ Assumes
      ▼
Lambda Execution Role
      │
      │ Has attached permissions
      ▼
IAM Policies
      │
      ├── Describe EC2 Instances
      ├── Start EC2 Instances
      ├── Stop EC2 Instances
      └── Write Logs to CloudWatch
```

## 2️⃣ EventBridge Scheduler Execution Role

The EventBridge Scheduler execution role is assumed by:

```text
scheduler.amazonaws.com
```

Its purpose is to allow EventBridge Scheduler to invoke the Lambda function.

Required permission:

```text
lambda:InvokeFunction
```

### EventBridge Permission Flow

```text
EventBridge Scheduler
        │
        │ Assumes
        ▼
Scheduler Execution Role
        │
        │ Permission
        ▼
lambda:InvokeFunction
        │
        ▼
AWS Lambda Function
```

## 🔑 IAM Policy vs IAM Role

| IAM Policy | IAM Role |
|:---|:---|
| Defines **what actions are allowed** | Defines **who can use permissions** |
| Contains permissions such as `ec2:StartInstances` | Can be assumed by Lambda, EventBridge, EC2, etc. |
| Attached to users, groups, or roles | Has policies attached to it |
| Defines **what can be done** | Defines **who can do it** |

# 🖥️ EC2 Instance Management

The Lambda function does not manage every EC2 instance in the AWS account.

It searches for instances with the following tag:

```text
Schedule = enabled
```

### Example EC2 Tags

| Tag Key | Tag Value | Purpose |
|:---|:---|:---|
| `Name` | `workhours-server-1` | Identifies the EC2 instance |
| `Schedule` | `enabled` | Allows Lambda to manage the instance |
| `Environment` | `dev` | Identifies the environment |

Example:

```text
Name = web-server
Schedule = enabled
Environment = dev
```

Any EC2 instance without:

```text
Schedule = enabled
```

will be ignored by the Lambda function.

# 🧠 Lambda Function Logic

The Lambda function performs the following steps.

### 1️⃣ Receive the Event

The EventBridge Scheduler sends an input event.

For the start schedule:

```json
{
  "action": "start"
}
```

For the stop schedule:

```json
{
  "action": "stop"
}
```

### 2️⃣ Validate the Action

The Lambda function checks whether the received action is valid:

```text
start
```

or:

```text
stop
```

If an invalid action is received, the function returns an error.

### 3️⃣ Initialize the EC2 Client

The Lambda function uses Python's Boto3 SDK to communicate with Amazon EC2.

```text
Boto3
   │
   ▼
EC2 Client
```

### 4️⃣ Find Tagged EC2 Instances

The Lambda function searches for instances with:

```text
tag:Schedule = enabled
```

It checks instances in the following states:

```text
running
stopped
```

### 5️⃣ Perform the Requested Action

#### When the action is `start`

The Lambda function:

- Finds instances with `Schedule=enabled`
- Checks their current state
- Starts instances that are `stopped`
- Skips instances that are already `running`

#### When the action is `stop`

The Lambda function:

- Finds instances with `Schedule=enabled`
- Checks their current state
- Stops instances that are `running`
- Skips instances that are already `stopped`

# 🔄 Automation Flow

## 🟢 Morning — Start EC2 Instances

At **8:00 AM from Monday to Friday**:

```text
8:00 AM
   │
   ▼
EventBridge Scheduler
   │
   │ Sends {"action":"start"}
   ▼
AWS Lambda
   │
   ▼
Find EC2 Instances
with Schedule=enabled
   │
   ▼
Check Instance State
   │
   ▼
Start Stopped Instances
```

## 🔴 Evening — Stop EC2 Instances

At **7:00 PM from Monday to Friday**:

```text
7:00 PM
   │
   ▼
EventBridge Scheduler
   │
   │ Sends {"action":"stop"}
   ▼
AWS Lambda
   │
   ▼
Find EC2 Instances
with Schedule=enabled
   │
   ▼
Check Instance State
   │
   ▼
Stop Running Instances
```

# 📡 EventBridge Scheduler

The project creates **two EventBridge Scheduler schedules**.

## 🟢 EC2 Start Schedule

**Schedule Name:**

```text
ec2-start-schedule
```

**Schedule Expression:**

```text
cron(0 8 ? * MON-FRI *)
```

**Input sent to Lambda:**

```json
{
  "action": "start"
}
```

## 🔴 EC2 Stop Schedule

**Schedule Name:**

```text
ec2-stop-schedule
```

**Schedule Expression:**

```text
cron(0 19 ? * MON-FRI *)
```

**Input sent to Lambda:**

```json
{
  "action": "stop"
}
```

# 📚 What I Learned

- ✅ **Infrastructure as Code** – Provisioning AWS infrastructure using Terraform
- ✅ **IAM Policies** – Defining permissions for AWS services
- ✅ **IAM Roles** – Allowing AWS services to assume identities and use permissions
- ✅ **AWS Lambda** – Building serverless automation with Python
- ✅ **Boto3** – Interacting with AWS services programmatically
- ✅ **Amazon EC2 Automation** – Starting and stopping instances using AWS APIs
- ✅ **Amazon EventBridge Scheduler** – Creating scheduled AWS automation
- ✅ **Lambda Permissions** – Controlling which services can invoke Lambda
- ✅ **CloudWatch Logs** – Monitoring and troubleshooting serverless applications
- ✅ **Tag-Based Automation** – Dynamically selecting AWS resources using tags
- ✅ **AWS Security** – Using IAM roles and controlled permissions
- ✅ **Time Zone Scheduling** – Configuring automation using `Asia/Colombo`

# 🎓 Key Concepts Demonstrated

### 🏗️ Infrastructure as Code

All AWS infrastructure is provisioned using Terraform instead of manually creating resources through the AWS Console.

### ⚡ Serverless Automation

The Lambda function runs only when triggered by EventBridge Scheduler.

### 🏷️ Dynamic Resource Discovery

The Lambda function does not use hardcoded EC2 instance IDs. Instead, it dynamically finds instances using:

```text
Schedule = enabled
```

### 🔄 State-Aware Automation

The Lambda function checks the current EC2 instance state before performing an action.

```text
START Action
    │
    ├── Instance already running → Skip
    │
    └── Instance stopped → Start
```

```text
STOP Action
    │
    ├── Instance already stopped → Skip
    │
    └── Instance running → Stop
```

This makes the automation safer and prevents unnecessary API calls.


⭐ Star this repository if you found it helpful!
