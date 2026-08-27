import boto3
import logging
import os

# Setup logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):

    try:
        # 1. Get action from event
        action = event.get('action')
        logger.info(f"Received action: {action}")
        
        # 2. Validate action
        if action not in ['start', 'stop']:
            logger.error(f"Invalid action: {action}")
            return {
                'statusCode': 400,
                'body': f'Invalid action: {action}'
            }
        
        # 3. Initialize EC2 client
        ec2 = boto3.client('ec2')
        
        # 4. Find instances with Schedule=WorkHours
        response = ec2.describe_instances(
            Filters=[
                {
                    'Name': 'tag:Schedule',
                    'Values': ['enabled']
                },
                {
                    'Name': 'instance-state-name',
                    'Values': ['running', 'stopped']
                }
            ]
        )
        
        # 5. Extract instance IDs
        instance_ids = []
        for reservation in response['Reservations']:
            for instance in reservation['Instances']:
                instance_ids.append(instance['InstanceId'])
        
        logger.info(f"Found {len(instance_ids)} instances with Schedule=enabled")
        
        if not instance_ids:
            logger.info("No instances to manage")
            return {
                'statusCode': 200,
                'body': 'No instances found with Schedule=enabled'
            }
        
        # 6. Perform action based on current state
        result = []
        for instance_id in instance_ids:
            # Get current state
            state_response = ec2.describe_instances(
                InstanceIds=[instance_id]
            )
            current_state = state_response['Reservations'][0]['Instances'][0]['State']['Name']
            
            # Determine if action is needed
            if action == 'start' and current_state == 'stopped':
                logger.info(f"Starting instance {instance_id}")
                ec2.start_instances(InstanceIds=[instance_id])
                result.append(f"Started {instance_id}")
            
            elif action == 'stop' and current_state == 'running':
                logger.info(f"Stopping instance {instance_id}")
                ec2.stop_instances(InstanceIds=[instance_id])
                result.append(f"Stopped {instance_id}")
            
            else:
                logger.info(f"Instance {instance_id} already {current_state}, skipping")
                result.append(f"Instance {instance_id} already {current_state}")
        
        logger.info(f"Action completed: {', '.join(result)}")
        
        return {
            'statusCode': 200,
            'body': f"Action '{action}' completed: {', '.join(result)}"
        }
        
    except Exception as e:
        logger.error(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'body': f"Error: {str(e)}"
        }