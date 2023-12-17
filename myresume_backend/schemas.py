"""
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# Start of lambda schema definition code:  src/sampleLambda/schema.py
"""

INPUT_SCHEMA = {
    "$schema": "http://json-schema.org/draft-07/schema",
    "$id": "http://example.com/example.json",
    "type": "object",
    "title": "Sample input schema",
    "description": "The Document generation path parameters, Document Type and Customer ID.",
    "required": ["pathParameters","queryStringParameters"],
    "properties": {
        "pathParameters" : { 
            "$id": "#/properties/pathParameters",
            "type": "object",
            "required": ["page-id"],
            "properties": {
                "page-id": {
                    "$id": "#/properties/pathParameters/page-id",
                    "type": "string",
                    "title": "The uuid of the webpage",
                    "examples": ["6632d5b4-5655-4c48-b7b6-071d5823c888"],
                    "maxLength": 36,
                }
            }
        },
        "queryStringParameters" : { 
            "$id": "#/properties/queryStringParameters",
            "type": "object",
            "required": ["func"],
            "properties": {
                "func": {
                    "$id": "#/properties/queryStringParameters/func",
                    "type": "string",
                    "title": "The function name of API Gateway",
                    "examples": ["getVisitorCount","addOneVisitorCount"],
                    "maxLength": 30,
                }
            }
        }
    },
}

OUTPUT_SCHEMA = {
    "$schema": "http://json-schema.org/draft-07/schema",
    "$id": "http://example.com/example.json",
    "type": "object",
    "title": "Sample outgoing schema",
    "description": "The root schema comprises the entire JSON document.",
    "examples": [{"statusCode": 200, "body": "OK"}],
    "required": ["statusCode", "body"],
    "properties": {
        "statusCode": {"$id": "#/properties/statusCode", "type": "integer", "title": "The statusCode"},
        "body": {"$id": "#/properties/body", "type": "string", "title": "The response"}
    },
}

# End of schema definition code