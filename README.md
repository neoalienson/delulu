#Development

##Prerequisites
1. NodeJS
2. Download and install [Parse command line tool](https://parse.com/apps/quickstart#cloud_code) (for deployment only).

##Setup for development
1. Checkout code.
2. run `npm install`

To run local development server:

`npm run dev`

#Deployment

##Setup for deployment

Create a file `config/global.json` with the following content:

    {
      "global": {
        "parseVersion": "1.4.2"
      },
      "applications": {
        "DH": {
          "applicationId": "",
          "masterKey": ""
        },
        "_default": {
          "link": "DH"
        }
      }
    }

Find the `applicationId` and `masterKey` from Parse.com console

##How to deploy

To build and deploy deployment

`npm run build && npm run deploy`
