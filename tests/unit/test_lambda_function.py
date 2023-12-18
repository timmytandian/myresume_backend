import sys
import os
import json
from unittest import TestCase
from unittest.mock import MagicMock, patch
from boto3 import resource, client
import moto
from aws_lambda_powertools.utilities.validation import validate

# [0] Import the Globals, Classes, Schemas, and Functions from the Lambda Handler
sys.path.append('./myresume_backend')
from myresume_backend.lambda_function import LambdaDynamoDBClass   # pylint: disable=wrong-import-position
from myresume_backend.lambda_function import lambda_handler, getVisitorsCount  # pylint: disable=wrong-import-position
from myresume_backend.schemas import INPUT_SCHEMA                     # pylint: disable=wrong-import-position

# [1] Mock all AWS Services in use
@moto.mock_dynamodb
class TestLambdaFunction(TestCase):
    """
    Test class for the application sample AWS Lambda Function
    """

    # Test Setup
    def setUp(self) -> None:
        """
        Create mocked resources for use during tests
        """

        # [2] Mock environment & override resources
        self.test_ddb_table_name = "unit_test_ddb"
        os.environ["DYNAMODB_TABLE_NAME"] = self.test_ddb_table_name
        
        # [3] Set up the services: construct a (mocked!) DynamoDB table
        dynamodb = resource("dynamodb", region_name="ap-northeast-1")
        dynamodb.create_table(
            TableName = self.test_ddb_table_name,
            KeySchema=[{"AttributeName": "pkey_uuid", "KeyType": "HASH"}],
            AttributeDefinitions=[{"AttributeName": "pkey_uuid", "AttributeType": "S"}],
            BillingMode='PAY_PER_REQUEST'
            )

        # [4] Establish the "GLOBAL" environment for use in tests.
        mocked_dynamodb_resource = resource("dynamodb")
        mocked_dynamodb_resource = { "resource" : resource('dynamodb'),
                                     "table_name" : self.test_ddb_table_name  }
        self.mocked_dynamodb_class = LambdaDynamoDBClass(mocked_dynamodb_resource)


    def test_getVisitorsCount(self) -> None:
        """
        Verify given correct parameters, return page's visitors count 
        which is retrieved from DynamoDB.
        """

        # [5] Post test items to a mocked database
        self.mocked_dynamodb_class.table.put_item(Item={"pkey_uuid": "12345678-1234-5678-1234-56781234",
                                                        "visit_count":42
                                                        })

        # [6] Run DynamoDB to S3 file function
        test_return_value = getVisitorsCount(
                        dynamo_db = self.mocked_dynamodb_class,
                        page_id="12345678-1234-5678-1234-56781234"
                        )

        # Test
        self.assertEqual(test_return_value["statusCode"], 200)
        self.assertEqual(test_return_value["body"], "42")


    def test_getVisitorsCount_pageid_notfound_404(self) -> None:
        """
        Verify given a page-id not present in the table, a 404 error is returned.
        """
        # [8] Post test items to a mocked database
        self.mocked_dynamodb_class.table.put_item(Item={"pkey_uuid": "12345678-1234-5678-1234-56781234",
                                                        "visit_count":42
                                                        })

        test_return_value = getVisitorsCount(
                        dynamo_db = self.mocked_dynamodb_class,
                        page_id="NOTVALID-1234-5678-1234-56781234"
                        )

        # Test
        self.assertEqual(test_return_value["statusCode"], 404)
        self.assertIn("Not Found", test_return_value["body"])


    # [12] Load and validate test events from the file system
    def load_sample_event_from_file(self, test_event_file_name: str) ->  dict:
        """
        Loads and validate test events from the file system
        """
        event_file_name = f"tests/events/{test_event_file_name}.json"
        with open(event_file_name, "r", encoding='UTF-8') as file_handle:
            event = json.load(file_handle)
            validate(event=event, schema=INPUT_SCHEMA)
            return event
        
    
    # [13] Patch the Global Class and any function calls
    @patch("myresume_backend.lambda_function.LambdaDynamoDBClass")
    @patch("myresume_backend.lambda_function.getVisitorsCount")
    def test_lambda_handler_getVisitorsCount_valid_event_returns_200(self,
                            patch_getVisitorsCount : MagicMock,
                            patch_lambda_dynamodb_class : MagicMock
                            ):
        """
        Verify 1) the event is parsed, 2) AWS resources are passed, 
        3) the getVisitorsCount function is called, and 
        4) a status code 200 is returned.
        """

        # [14] Test setup - Return a mock for the global variables and resources
        patch_lambda_dynamodb_class.return_value = self.mocked_dynamodb_class
        
        return_value_200 = {"statusCode" : 200, "body":"OK"}
        patch_getVisitorsCount.return_value = return_value_200

        # [15] Run Test using a test event from /tests/events/*.json
        test_event = self.load_sample_event_from_file("sampleEvent_getVisitorCount")
        test_return_value = lambda_handler(event=test_event, context=None)

        # [16] Validate the function was called with the mocked globals
        # and event values
        patch_getVisitorsCount.assert_called_once_with(
                                        dynamo_db=self.mocked_dynamodb_class,
                                        page_id=test_event["pathParameters"]["page-id"])

        self.assertEqual(test_return_value, return_value_200)


    # [17] Patch the Global Class and any function calls
    @patch("myresume_backend.lambda_function.LambdaDynamoDBClass")
    @patch("myresume_backend.lambda_function.addOneVisitorCount")
    def test_lambda_handler_addOneVisitorCount_valid_event_returns_200(self,
                            patch_addOneVisitorCount : MagicMock,
                            patch_lambda_dynamodb_class : MagicMock
                            ):
        """
        Verify 1) the event is parsed, 2) AWS resources are passed, 
        3) the addOneVisitorCount function is called, and 
        4) a status code 200 is returned.
        """

        # [18] Test setup - Return a mock for the global variables and resources
        patch_lambda_dynamodb_class.return_value = self.mocked_dynamodb_class
        
        return_value_200 = {"statusCode" : 200, "body":"OK"}
        patch_addOneVisitorCount.return_value = return_value_200

        # [19] Run Test using a test event from /tests/events/*.json
        test_event = self.load_sample_event_from_file("sampleEvent_addOneVisitorCount")
        test_return_value = lambda_handler(event=test_event, context=None)

        # [20] Validate the function was called with the mocked globals
        # and event values
        patch_addOneVisitorCount.assert_called_once_with(
                                        dynamo_db=self.mocked_dynamodb_class,
                                        page_id=test_event["pathParameters"]["page-id"])

        self.assertEqual(test_return_value, return_value_200)

    def tearDown(self) -> None:
        # [14] Remove (mocked!) DynamoDB Table
        dynamodb_resource = client("dynamodb", region_name="ap-northeast-1")
        dynamodb_resource.delete_table(TableName = self.test_ddb_table_name )
