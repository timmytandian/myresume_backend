import simplejson as json
import boto3
import botocore
import logging
from os import environ

DDB_TABLE_NAME = environ.get("DYNAMODB_TABLE_NAME","NONE")

# A custom class to catch error when 
# the request from API Gateway cannot be handled
class ApiRequestNotFoundError(LookupError):
    pass

def respond(err, res=None):
    return {
        'statusCode': 400 if err else 200,
        'body': err if err else res,
        'headers': {
            'Content-Type': 'application/json',
            
        },
    }

def table_get_item(table, partitionKey, partitionKeyVal):
    response = table.get_item(
                Key={
                    partitionKey: partitionKeyVal,
                    
                },
                ConsistentRead=False
    )
    return response

def table_update_item_plus1(table, partitionKey, partitionKeyVal, updateAttr1):
    response = table.update_item(
                Key={
                    partitionKey: partitionKeyVal,
                    
                },
                UpdateExpression='SET #updateAttr1 = #updateAttr1 + :val',
                ExpressionAttributeNames={
                    '#updateAttr1': updateAttr1
                },
                ExpressionAttributeValues={
                    ":val": 1
                },
                ReturnValues='UPDATED_NEW'
    )
    return response

def extract_visit_count_from_response(res):
    try:
        for key in res:
            if(res[key].get('visit_count')):
                visitCount = int(res[key].get('visit_count'))
                return visitCount
        raise KeyError ('"visit_count" attribute is expected but not found in the database response. Check again the page-id.')
    except KeyError as e:
        logging.error(e)
        return e.args[0]
    except Exception as e:
        errorMessage = 'An unexpected occured, unable to extract visitor count from database response. Details:{}'.format(e)
        logging.error(errorMessage)
        return errorMessage

def lambda_handler(event, context):
    # check boto version for future debugging
    logging.debug('botocore version: {0}'.format(botocore.__version__))
    logging.debug('boto3 version: {0}'.format(boto3.__version__))
    
    # define some variables related to DynamoDB
    dynamodb = boto3.resource("dynamodb")
    ddbTable = dynamodb.Table(DDB_TABLE_NAME)
    ddbPartKey = "pkey_uuid"
    ddbAttribute = "visit_count"
    
    try:
        
        # parse event object from API Gateway
        routeKey = event.get('routeKey', '{}')
        functionName = event.get('queryStringParameters', {"func":"{}"}).get('func','{}')
        pageId = event.get('pathParameters', '{}').get('page-id','{}')
        
        if (routeKey == 'GET /counts/{page-id}') and (functionName == "getVisitorCount"):
            dbResponse = table_get_item(ddbTable, ddbPartKey, pageId)
            logging.info('dbResponse: {}'.format(dbResponse))
            response = extract_visit_count_from_response(dbResponse)
            #response = dbResponse # this line is only for debugging purpose
        elif (routeKey == 'GET /counts/{page-id}') and (functionName == "addOneVisitorCount"):
            dbResponse = table_update_item_plus1(ddbTable, ddbPartKey, pageId, ddbAttribute)
            logging.info('dbResponse: {}'.format(dbResponse))
            response = extract_visit_count_from_response(dbResponse)
            #response = dbResponse # this line is only for debugging purpose
        else:
            raise ApiRequestNotFoundError("Requested path or parameter not found")
            
        
        # log troubleshooting message
        logging.info('event: {}'.format(event))
        logging.info('response: {}'.format(response))
        
        # if everything is successful, return the DynamoDB response
        return respond(err=None, res=json.dumps(response))
    
        
    except botocore.exceptions.ClientError as e:
        response = {
            "errorCode":'botocore.{}'.format(e.response['Error']['Code']),
            "errorMessage":e.response['Error']['Message'],
            "routeKey":routeKey,
            "pathParameters":event.get('pathParameters','{}'),
            "queryStringParameters":event.get('queryStringParameters','{}'),
        }
        if (e.response['Error']['Code'] == "ValidationException"):
            response['errorMessage'] = "the provided attribute or partition key item is not found in DynamoDB."
        logging.error(response['errorMessage'], extra=response)
        return respond(err=json.dumps(response))
    except KeyError as e:
        keyErrorMsg = 'KeyError occured. The key named "{}" is expected, but not found in the request payload.'.format(e)
        logging.error(keyErrorMsg)
        return respond(err=keyErrorMsg)
    except ApiRequestNotFoundError as e:
        response = {
            "errorMessage":e.args[0],
            "routeKey":routeKey,
            "pathParameters":event.get('pathParameters','{}'),
            "queryStringParameters":event.get('queryStringParameters','{}'),
        }
        logging.error(response['errorMessage'], extra=response)
        return respond(err=json.dumps(response))