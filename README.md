az deployment group create --resource-group ${{ parameters.resourceGroupName }} --subscription ${{ parameters.subscriptionID }} --template-file ${{ parameters.templateFile }} --parameters ${{ parameters.parametersFile }} --parameters dbPassword="${{ parameters.dbPassword }}"

az deployment group create --resource-group terraform.prod --subscription 72a3f9e6-ddb2-4621-91ef-b5dd758420d1 --template-file test/test.bicep --parameters test/main.parameters.test.json
