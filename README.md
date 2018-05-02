# Overview

This is a repository containing the sources of an API proxy used for the Apigee CI/CD demo available [here](https://github.com/apichick/apigee-ci-cd-demo)

The proxy is built and deployed using the Apigee Maven Deploy plugin:

* [Deploy Plugin](https://github.com/apigee/apigee-deploy-maven-plugin)

The environment and organization configuration is setup using the Apigee Maven config plugin:

* [Configuration Plugin](https://github.com/apigee/apigee-config-maven-plugin)

For unit testing the Javascript code used in the Apigee policies we are using Jest:

* [Jest](https://facebook.github.io/jest/)

For integration testing we are using cucumber-js + apickli:

* [cucumber-js](https://github.com/cucumber/cucumber-js)
* [apickli](https://github.com/apickli/apickli)

# Build Process Description

See below a list of the tasks run by the Maven build script:

1. Cleaning the target folder

2. Running static code analysis of the Javascript sources present in the apiproxy/resources/jsc directory using jshint.

3. Installing the required dependencies and running unit tests of the Javascript code used in the policies using Jest. 

3. Copying the apiproxy and config directories to the target directory while replacing the Maven properties in the tokenized files inside those directories. 

4. Updating (or creating if they do not exist already) the following environment entities: cache, key-value map, target server.

5. Creating the bundle and deploying it to the selected environment in the organization.

6. Updating (or creating if they do not exist already) the following organization entities: developer, API product. The API product created includes the proxy that has just been deployed.

7. Deleting (if it exists) and creating a developer app for the developer and API product created before. Unlike for the other entities in this case we prefer not update because each time the developer app get updated new credentials are created. If we do that as part of our CI/CD process, we can end up with an app with thousands for credentials.

8. Exporting the credentials for the developer apps existing in the organization and getting the API key for the developer app that was just created.

9. Installing the required dependencies and running the integration tests for that API proxy using the API key obtained in the previous step.

# Running Maven manually

The command required to trigger the build, deployment and test manually is the following one:

    $ mvn install -Dorg={APIGEE_ORGANIZATION} -Denv={APIGEE_ENVIRONMENT} -Dusername={APIGEE_USERNAME} -Dpassword={APIGEE_PASSWORD}

When running the command like this we will end up with the following:

    Proxy

    Name: book-api-{USERNAME}-v1
    Base path: /book-{USERNAME}/v1

    Environment entities

    Cache: book-api-USERNAME}-v1-response-cache
    KVM: book-api-{USERNAME}-v1-configuration
    Target Server: library-api-{USERNAME}-v1

    Organization entities

    Developer: john.doe@acme.com
    API Product: book-api-{USERNAME}-v1-api-product (including API proxy book-api-{USERNAME}-v1 and available in {APIGEE_ENVIRONMENT})
    Developer App: book-api-{USERNAME}-v1-app (for API product book-api-{USERNAME}-v1-api-product and developer john.doe@acme.com)

    NOTE: {USERNAME} is the username of the machine the script has been run from.


# Running Maven from Jenkins

Have a look at the Jenkinsfile [here](./Jenkinsfile)

* When building a feature branch we will end up with the following:

        Proxy deployed in the environment used for development

        Name: book-api-jenkins-v1
        Base path: /book-jenkins/v1

        Entities in the environment used for development

        Cache: book-api-jenkins-v1-response-cache in 
        KVM: book-api-jenkins-v1-configuration
        Target Server: library-api-jenkins-v1

        Entities in the organization

        Developer: john.doe@acme.com
        API Product: book-api-jenkins-v1-api-product (including API proxy book-api-jenkins-v1 and available in then environment used for development)
        Developer App: book-api-jenkins-v1-app (for API product book-api-jenkins-v1-api-product and developer john.doe@acme.com)


* When building the master branch we will end up with the following:

        Proxy deployed in the environment used for development

        Name: book-api-v1
        Base path: /book/v1

        Entities in the environment used for development

        Cache: book-api-v1-response-cache
        KVM: book-api-v1-configuration
        Target Server: library-api-v1

        Entities in the organization

        Developer: john.doe@acme.com
        API Product: book-api-v1-api-product (including API proxy book-api-v1 and available in the environment used for development)
        Developer App: book-api-v1-app (for API product book-api-v1-api-product and developer john.doe@acme.com)

* When building the branches corresponding to all the environments except the one we are using as development environment we will end up with the following:

        Proxy deployed in the environment with the same name as the branch

        Name: book-api-v1
        Base path: /book/v1

        Entities in the environment with the same name as the branch

        Cache: book-api-v1-response-cache
        KVM: book-api-v1-configuration
        Target Server: library-api-v1

        Entities in the organization

        Developer: john.doe@acme.com
        API Product: book-api-{BRANCH_NAME}-v1-api-product (including API proxy book-api-v1 and available in environment with name {BRANCH_NAME})
        Developer App: book-api-{BRANCH_NAME}-v1-app (for API product book-api-{BRANCH_NAME}-v1-api-product and developer john.doe@acme.com)
