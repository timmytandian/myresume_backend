from os import environ
from typing import Any, Dict
from boto3 import resource
import botocore.exceptions
from aws_lambda_powertools.utilities.data_classes import APIGatewayProxyEvent
from aws_lambda_powertools.utilities.typing import LambdaContext
from aws_lambda_powertools.utilities.validation import validator


# Reference: 
# github: https://github.com/aws-samples/serverless-test-samples/blob/main/python-test-samples/lambda-mock/src/sample_lambda/app.py
# AWS blog: https://aws.amazon.com/blogs/devops/unit-testing-aws-lambda-with-python-and-mock-aws-services/

# Import the schema for the Lambda Powertools Validator
from schemas import INPUT_SCHEMA, OUTPUT_SCHEMA

# Prepare globally scoped resources
# Initialize the resources once per Lambda execution environment by using global scope.
_AWS_REGION = 'ap-northeast-1'
_LAMBDA_DYNAMODB_RESOURCE = { "resource" : resource('dynamodb', region_name=_AWS_REGION), 
                              "table_name" : environ.get("DYNAMODB_TABLE_NAME","NONE") }

# A custom class to catch error when 
# the request from API Gateway cannot be handled
class ApiRequestNotFoundError(LookupError):
    pass

# Define a Global class an AWS Resource: Amazon DynamoDB. 
class LambdaDynamoDBClass:
    """
    AWS DynamoDB Resource Class
    """
    def __init__(self, lambda_dynamodb_resource):
        """
        Initialize a DynamoDB Resource
        """
        self.resource = lambda_dynamodb_resource["resource"]
        self.table_name = lambda_dynamodb_resource["table_name"]
        self.table = self.resource.Table(self.table_name)

# Validate the event schema and return schema using Lambda Power Tools
@validator(inbound_schema=INPUT_SCHEMA, outbound_schema=OUTPUT_SCHEMA)
def lambda_handler(event: APIGatewayProxyEvent,context: LambdaContext) -> Dict[str, Any]:
    """
    Lambda Entry Point
    """
    # Use the Global variables to optimize AWS resource connections
    global _LAMBDA_DYNAMODB_RESOURCE

    try:
        # parse event object from API Gateway
        routeKey = event.get('routeKey', '{}')
        functionName = event.get('queryStringParameters', {"func":"{}"}).get('func','{}')
        pageId = event.get('pathParameters', '{}').get('page-id','{}')

        # initialize the AWS DynamoDB resource
        dynamodb_resource_class = LambdaDynamoDBClass(_LAMBDA_DYNAMODB_RESOURCE)

        # execute the API depending on the function name
        if (routeKey == 'GET /counts/{page-id}') and (functionName == "getVisitorCount"):
            return getVisitorsCount(dynamo_db=dynamodb_resource_class,
                                    page_id=pageId)
        elif (routeKey == 'GET /counts/{page-id}') and (functionName == "addOneVisitorCount"):
            return addOneVisitorCount(  dynamo_db=dynamodb_resource_class,
                                        page_id=pageId)
        else:
            raise ApiRequestNotFoundError("Requested path or parameter not found")
    
    except ApiRequestNotFoundError as api_error:
        body = "Not Found: " + api_error.args[0]
        status_code = 404
        return {"statusCode": status_code, "body" : body }
    

def getVisitorsCount( dynamo_db: LambdaDynamoDBClass,
                      page_id: str) -> dict:
    """
    Given a page id, return page's visitors count which is retrieved from
     DynamoDB.
    """

    # default output as placeholder
    status_code = 200
    body = "0"

    try:         
        # Use the passed environment class for AWS resource access to read from the DB
        dbResponse = dynamo_db.table.get_item(  Key={"pkey_uuid": page_id},
                                                ConsistentRead=False)
        visitorCount = extract_visit_count_from_dbresponse(dbResponse)
        body = f"{visitorCount}"
    except KeyError as index_error:
        body = "Not Found: " + str(index_error)
        status_code = 404
    except Exception as other_error:               
        body = "ERROR: " + str(other_error)
        status_code = 500
    finally:
        print("this is from ci/cd.")
        print(body)
        return {"statusCode": status_code, "body" : body }

def addOneVisitorCount(dynamo_db: LambdaDynamoDBClass,
                       page_id: str) -> dict:
    """
    Given a page id, return page's visitors count which has been added by one.
    """

    # default output as placeholder
    status_code = 200
    body = "0"
    
    try:         
        # Use the passed environment class for AWS resource access to update the DB
        dbResponse = dynamo_db.table.update_item(   Key={
                                                        "pkey_uuid": page_id
                                                    },
                                                    UpdateExpression='SET #updateAttr1 = #updateAttr1 + :val',
                                                    ExpressionAttributeNames={
                                                        '#updateAttr1': "visit_count"
                                                    },
                                                    ExpressionAttributeValues={
                                                        ":val": 1
                                                    },
                                                    ReturnValues='UPDATED_NEW'
                                                )
        visitorCount = extract_visit_count_from_dbresponse(dbResponse)
        body = f"{visitorCount}"

    except KeyError as index_error:
        body = "Not Found: " + str(index_error)
        status_code = 404
    except botocore.exceptions.ClientError as dynamodb_error:
        body = "Not Found: " + str(dynamodb_error)
        status_code = 404
    except Exception as other_error:               
        body = "ERROR: " + str(other_error)
        status_code = 500
    finally:
        print(body)
        return {"statusCode": status_code, "body" : body }


def extract_visit_count_from_dbresponse(dbResponse) -> int:
    """
    Extract the "visit_count" value from the json payload of the DB response.
    Return integer.
    """
    
    # naively iterate for all keys in the DB response payload to look for "visit_count"
    for key in dbResponse:
        if(dbResponse[key].get('visit_count')):
            visitCount = int(dbResponse[key].get('visit_count'))
            return visitCount
    raise KeyError ('"visit_count" attribute is expected but not found in the database response. Check again the page-id.')


# I used the 'main' part below when developing/debugging in my local machine.
# The 'main' part below is not necessary when deploying the code to Lambda.
'''
from aws_lambda_powertools.utilities.validation.exceptions import SchemaValidationError
import sys
import json # for testing

def main(argv):
    # parse input argument
    try:
        sampleEventFile = argv[1]
    except IndexError:
        sampleEventFile = "getVisitorCount"
    
    # Read event from json for testing
    eventFileName = f"tests/events/sampleEvent_{sampleEventFile}.json"
    with open(eventFileName,"r",encoding='UTF-8') as fileHandle:
        event = json.load(fileHandle)
    
    try:
        return lambda_handler(event, None)
    except SchemaValidationError as schema_error:
        body = "Bad Request: " + schema_error.args[0]
        status_code = 400
        return {"statusCode": status_code, "body" : body }


if __name__ == "__main__":
    main(sys.argv)
'''