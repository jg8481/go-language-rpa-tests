*** Settings ***

Library    ./resources/VegetaLoadTestLibrary.py
Library    ./resources/PrismMockServerLibrary.py
Library    ./resources/ToxiproxyChaosTestLibrary.py
Library    OperatingSystem
Library    Process
Library    String
Library    Collections

Test Teardown     Trigger Only After Failure

*** Variables ***

${USER_DEFINED_TEST_RATE}     100
## The following variable only accepts seconds as the duration.
${USER_DEFINED_TEST_DURATION}    10s
${USER_DEFINED_METHOD}   GET
${USER_DEFINED_TEST_OUTPUT_FILE}    results.bin
## The following is an empty request body for GET requests.
${USER_DEFINED_TEST_REQUEST_BODY}   ${EMPTY}

*** Test Cases ***

FUNCTIONAL TESTS SETUP : Start the Prism API Mock Server for the Go Httpstat functional tests and Vegeta Load Tests.
    [Tags]    Tests_Setup   Run_All_Tests
    Automation Section For Slack Notifications    FUNCTIONAL TESTS SETUP
    Log Lines To Console
    Start Prism API Mock Server
    Log Lines To Console

CHAOS AND LOAD TESTS SETUP : Start the Toxiproxy TCP Chaos Proxy.
    [Tags]    Tests_Setup    Run_All_Tests
    Automation Section For Slack Notifications    CHAOS AND LOAD TESTS SETUP
    Log Lines To Console
    Start Toxiproxy TCP Proxy
    Log Lines To Console

MODEL-BASED CHAOS TESTS SETUP : Create a new Graphwalker Path File for the Model-Based Chaos Tests. The Graphwalker Model combines API Functional Test, Chaos Test, and Mutational Fuzz Test strategies.
    [Tags]    Tests_Setup    Run_All_Tests
    Automation Section For Slack Notifications    MODEL-BASED CHAOS TESTS SETUP
    Log Lines To Console
    Create Graphwalker Path File
    Log Lines To Console

MODEL-BASED CHAOS TESTS RUNNER : Run the Graphwalker Path File for the Model-Based Chaos Tests. The Graphwalker Model combines API Functional Test, Chaos Test, and Mutational Fuzz Test strategies.
    [Tags]    Model-Based_Tests    Exploratory_Tests    Chaos_Tests    Run_All_Tests
    Automation Section For Slack Notifications    MODEL-BASED CHAOS TESTS RUNNER
    Log Lines To Console
    Run Graphwalker Model Based Tests    GraphwalkerPath.csv
    Log Lines To Console

VEGETA CHAOS LOAD TESTS - RAMP UP RUNNER : Run the Vegeta Load Tests that connect to Toxiproxy and ramp up.
    [Tags]    Load_Tests    Chaos_Tests    Run_All_Tests
    Automation Section For Slack Notifications    VEGETA CHAOS LOAD TESTS - RAMP UP
    Log Lines To Console
    Run Ramp Up Load Test Connected To Toxiproxy
    Log Lines To Console

VEGETA CHAOS LOAD TESTS - CUSTOMIZED PARAMETERS RUNNER : Run the Vegeta Load Tests with custom user defined parameters. This can run for seconds, minutes, hours, days etc. as long as the duration is given a valid amount of seconds.
    [Tags]    Load_Tests    Chaos_Tests    Run_All_Tests
    Automation Section For Slack Notifications    VEGETA CHAOS LOAD TESTS - CUSTOMIZED PARAMETERS
    Log Lines To Console
    Run Custom Vegeta Load Test Connected To Toxiproxy    http://0.0.0.0:8080/store/order/9
    Log Lines To Console

GO TEST FUNCTIONAL TESTS - GET /USER/USERNAME : Analyze the Go Httpstat functional test for a GET request on the /user/vitae API endpoint
    [Tags]    robot:skip-on-failure    Functional_Tests_Analysis    Functional_Tests    Run_All_Tests
    Log Lines To Console
    Analyze Go Test Results    vitae    PASS
    Log Lines To Console

GO TEST FUNCTIONAL TESTS - GET /NO_AUTH/PETS/FINDBYSTATUS : Analyze the Go Httpstat functional test for a GET request on the /no_auth/pets/findByStatus API endpoint
    [Tags]    robot:skip-on-failure    Functional_Tests_Analysis    Functional_Tests    Run_All_Tests
    Log Lines To Console
    Analyze Go Test Results    findByStatus    PASS
    Log Lines To Console

GO TEST FUNCTIONAL TESTS - GET /STORE/ORDER/NUMBER : Analyze the Go Httpstat functional test for a GET request on the /store/order/9 API endpoint
    [Tags]    robot:skip-on-failure    Functional_Tests_Analysis    Functional_Tests    Run_All_Tests
    Log Lines To Console
    Analyze Go Test Results    store/order/9    PASS
    Log Lines To Console

GO TEST FUNCTIONAL TESTS - POST /STORE/ORDER : Analyze the Go Httpstat functional test for a POST request on the /store/order API endpoint. This will create a new order.
    [Tags]    robot:skip-on-failure    Functional_Tests_Analysis    Functional_Tests    Run_All_Tests
    Log Lines To Console
    Analyze Go Test Results    POST_http://0.0.0.0:4010/store/order    PASS
    Log Lines To Console

GO TEST FUNCTIONAL TESTS - POST /USER : Analyze the Go Httpstat functional test for a POST request on the /user API endpoint. This will create a new user.
    [Tags]    robot:skip-on-failure    Functional_Tests_Analysis    Functional_Tests    Run_All_Tests
    Log Lines To Console
    Analyze Go Test Results    POST_http://0.0.0.0:4010/user    PASS
    Log Lines To Console

*** Keywords ***

## --> Generic Keywords

Create Base64 JQ Output From Given String
    [Arguments]    ${STRING_INPUT}
    ${BASE64_OUTPUT}=    Run    echo -n '${STRING_INPUT}' | jq -r '@base64'
    RETURN    ${BASE64_OUTPUT}

Create Base64 JQ Output From Given File
    [Arguments]    ${FILE_NAME_INPUT}
    ${BASE64_OUTPUT}=    Run    cat ${EXECDIR}/resources/${FILE_NAME_INPUT} | jq -r '@base64'
    RETURN    ${BASE64_OUTPUT}

Automation Section For Slack Notifications
    [Arguments]    ${AUTOMATION_SECTION}
    Set Suite Variable    ${AUTOMATION_SECTION_NAME}    ${AUTOMATION_SECTION}

Trigger Only After Failure
    Run Keyword If Test Failed     Automation Failure Detected Notify Team

Automation Failure Detected Notify Team
    Send Short Message Through Slack After Any Automation Failures    generic-automation.robot file running various enhanced Go Language Test Tools    Docker Container Test

Send Short Message Through Slack After Any Automation Failures
    ## There are various solutions out there for sending Slack messages through automation frameworks. Here is an example of a generic Slack tool I have used in many projects.
    ##
    ## This slacktee tool is a very simple to use Slack client that you can use to pipe text into Slack channels...
    ## https://github.com/coursehero/slacktee
    ##
    ## To use this slacktee Slack bot automation, you must set up your own ".slacktee" config file using the given "template.slacktee".
    ## The advantage of slacktee is any programming language, Linux Shell, or automation framework that can run on Linux can utilize it to quickly create a simple Slack bot. It can quickly turn tests into monitoring processes.
    ##
    ## The following keyword will demonstrate slacktee...
    [Arguments]    ${TEST_NAME}    ${TEST_ENVIRONMENT}
    Run Process    echo "The ${TEST_NAME} failed in the ${TEST_ENVIRONMENT} environment. The automation section that failed was --> ${AUTOMATION_SECTION_NAME}" | slacktee.sh -i :nerd_face: --plain-text --config ${EXECDIR}/resources/.slacktee    shell=True    timeout=20s    on_timeout=continue

Log Lines To Console
    Log To Console    ...\n...\n...\n...

## --> Prism and Toxiproxy Keywords

Start Prism API Mock Server
    Remove File    ${EXECDIR}/resources/api-application.log
    Download And Install Prism
    Start Prism Mock Server
    Log To Console    Prism Mock Server Started
    Log To Console    Check the Mock API log found in... ${EXECDIR}/resources/api-application.log

Start Toxiproxy TCP Proxy
    Remove File    ${EXECDIR}/resources/toxiproxy.log
    Start Toxiproxy Server
    Create TCP Chaos Proxy
    Add Limited Bandwidth Toxic
    Add Slow Close Toxic
    Add Latency Toxic
    Log To Console    Toxiproxy Server Started
    Log To Console    Check the Toxiproxy log found in... ${EXECDIR}/resources/toxiproxy.log

## --> Go Language Go Test Keywords

Analyze Go Test Results
    [Arguments]    ${GO_TEST_OUTPUT_CHECK1}    ${GO_TEST_OUTPUT_CHECK2}
    ${GO_TEST_OUTPUT_CONTENTS}=    Run    cat ${EXECDIR}/resources/go-test-console-results.log | grep ${GO_TEST_OUTPUT_CHECK1}
    Log    ${GO_TEST_OUTPUT_CONTENTS}
    Should Contain    ${GO_TEST_OUTPUT_CONTENTS}    ${GO_TEST_OUTPUT_CHECK2}

## --> Go Language Vegeta Load Test Keywords

Run Ramp Up Load Test Connected To Toxiproxy
    Remove File    ${EXECDIR}/*.bin
    Run Vegeta Ramp Up Load Test    http://0.0.0.0:8080/user/vitae    GET
    Move Files    ${EXECDIR}/*.bin    ${EXECDIR}/results/
    Log To Console    Vegeta Load Test Completed
    Log To Console    Check the results.bin files found in... ${EXECDIR}/results

Run Custom Vegeta Load Test Connected To Toxiproxy
    [Arguments]    ${USER_DEFINED_URL}
    Remove File    ${EXECDIR}/*.bin
    Run Specific Parameters Vegeta Load Test    ${USER_DEFINED_TEST_RATE}    ${USER_DEFINED_TEST_DURATION}    ${USER_DEFINED_URL}    ${USER_DEFINED_METHOD}    ${USER_DEFINED_TEST_REQUEST_BODY}    ${USER_DEFINED_TEST_OUTPUT_FILE}
    Move Files    ${EXECDIR}/*.bin    ${EXECDIR}/results/
    Log To Console    Vegeta Load Test Completed
    Log To Console    Check the results.bin files found in... ${EXECDIR}/results

## --> Model-Based Testing Keywords

Create Graphwalker Path File
    Remove File    ${EXECDIR}/resources/GraphwalkerPath.csv
    Run Keyword And Ignore Error    Run    java -jar /usr/bin/graphwalker-cli-4.3.2.jar offline --start-element send_get_request_to_user_endpoint --model ${EXECDIR}/resources/GraphwalkerModel.graphml "random(edge_coverage(100))" | jq -r '.currentElementName' >> ${EXECDIR}/resources/GraphwalkerPath.csv
    Log To Console    Graphwalker Path File Created
    Log To Console    Check the Graphwalker Path File found in... ${EXECDIR}/resources/GraphwalkerPath.csv

Run Graphwalker Model Based Tests
    [Arguments]    ${GRAPHWALKER_CSV_FILE}
    ${GRAPHWALKER_CSV_FILE_CONTENTS}=     Get File    ${EXECDIR}/resources/${GRAPHWALKER_CSV_FILE}
    Log    ${GRAPHWALKER_CSV_FILE_CONTENTS}
    @{GRAPHWALKER_PATH_LINES}=    Get Graphwalker Path Keywords From CSV File    ${GRAPHWALKER_CSV_FILE_CONTENTS}
    Run Graphwalker Path Keywords    ${GRAPHWALKER_PATH_LINES}

Get Graphwalker Path Keywords From CSV File
    [Arguments]    ${GRAPHWALKER_CSV_CONTENT}
    @{GRAPHWALKER_LINES}=    Split To Lines    ${GRAPHWALKER_CSV_CONTENT}
    RETURN    @{GRAPHWALKER_LINES}

Run Graphwalker Path Keywords
    [Arguments]    ${GRAPHWALKER_CSV_LINES}
    FOR  ${GRAPHWALKER_PATH_KEYWORD}   IN   @{GRAPHWALKER_CSV_LINES}
        Run Keyword    ${GRAPHWALKER_PATH_KEYWORD}
    END

Run HTTPStat POST Request
    [Arguments]   ${TARGET_URL}    ${REQUEST_METHOD}    ${REQUEST_BODY}
    Remove File    ${EXECDIR}/resources/httpstat-graphwalker-response-output.log
    Run Keyword And Ignore Error    Run    go run httpstat-test-runner.go -url "${TARGET_URL}" -method "${REQUEST_METHOD}" -body ${REQUEST_BODY} > ${EXECDIR}/resources/httpstat-graphwalker-response-output.log

Run HTTPStat GET Request
    [Arguments]   ${TARGET_URL}    ${REQUEST_METHOD}
    Remove File    ${EXECDIR}/resources/httpstat-graphwalker-response-output.log
    Run Keyword And Ignore Error    Run    go run httpstat-test-runner.go -url "${TARGET_URL}" -method "${REQUEST_METHOD}" > ${EXECDIR}/resources/httpstat-graphwalker-response-output.log

restart_server
    Run Keyword And Ignore Error    Run    pkill prism > /dev/null 2>&1; pgrep prism | xargs kill > /dev/null 2>&1; killall prism > /dev/null 2>&1
    Sleep    30 seconds
    Start Prism Mock Server
    Sleep    30 seconds

check_api_response_log_files
    ${HTTPSTAT_RESPONSE_CONTENTS}=     Get File    ${EXECDIR}/resources/httpstat-graphwalker-response-output.log
    Log    ${HTTPSTAT_RESPONSE_CONTENTS}
    Should Not Contain Any    ${HTTPSTAT_RESPONSE_CONTENTS}    ERROR    error    errors    Not Allowed    no method    NO_METHOD_MATCHED_ERROR

check_server_log_files
    ## Un-comment this section if you want to test the slacktee Slack bot.
    ## Fail    Checking Slack notifications.
    ${API_SERVER_LOG_CONTENTS}=     Get File    ${EXECDIR}/resources/api-application.log
    Log    ${API_SERVER_LOG_CONTENTS}
    Should Not Contain Any   ${API_SERVER_LOG_CONTENTS}    UnhandledPromiseRejectionWarning    Unhandled    ERR_INVALID_CHAR    rejection    exception

send_get_request_to_order_endpoint
    Run HTTPStat GET Request    http://0.0.0.0:8080/store/order/9    GET

send_get_request_to_user_endpoint
    Run HTTPStat GET Request    http://0.0.0.0:8080/user/vitae    GET

send_get_request_to_pets_endpoint
    Run HTTPStat GET Request    http://0.0.0.0:8080/no_auth/pets/findByStatus?status=available    GET

send_post_request_to_order_endpoint
    Run HTTPStat POST Request    http://0.0.0.0:8080/store/order    POST    '{"id": 9, "petId": 9, "quantity": 1, "shipDate": "2021-07-29T00:00:00.000Z", "status": "placed", "complete": true}'

send_post_request_to_user_endpoint
    Run HTTPStat POST Request    http://0.0.0.0:8080/user    POST    '{"id": 1, "username": "user1", "firstName": "John", "lastName": "Doe", "email": "john.doe@example.com", "password": "123456", "phone": "1234567890", "userStatus": 1}'

add_toxiproxy_latency_then_send_user_get_request
    Remove All Three Toxics
    Sleep    30 seconds
    Add Latency Toxic

add_toxiproxy_slow_close_then_send_user_get_request
    Remove All Three Toxics
    Sleep    30 seconds
    Add Slow Close Toxic

add_toxiproxy_limited_bandwidth_then_send_user_get_request
    Remove All Three Toxics
    Sleep    30 seconds
    Add Limited Bandwidth Toxic

send_post_request_to_user_endpoint_with_fuzzed_data
    Run Keyword And Ignore Error    Run    echo '{"id": 1, "username": "user1", "firstName": "John", "lastName": "Doe", "email": "john.doe@example.com", "password": "123456", "phone": "1234567890", "userStatus": 1}' | radamsa > ${EXECDIR}/resources/mutational-fuzz-data-user-test.dat
    Run Keyword And Ignore Error    Run    httpstat -o ${EXECDIR}/resources/httpstat-response-mutational-fuzz-data-user-output.json -X POST -H 'Content-Type: application/json' -d @${EXECDIR}/resources/mutational-fuzz-data-user-test.dat http://0.0.0.0:8080/user
    Run Keyword And Ignore Error    Run    TIMESTAMP=$(date); echo "======== :: Fuzz Test Data Tracker for mutational-fuzz-data-user-test.dat -- Logged this on... $TIMESTAMP :: ========" >> ${EXECDIR}/results/mutational-fuzz-data-targeted-at-user-endpoint.log
    Run Keyword And Ignore Error    Run    echo " " >> ${EXECDIR}/results/mutational-fuzz-data-targeted-at-user-endpoint.log
    Run Keyword And Ignore Error    Run    cat ${EXECDIR}/resources/mutational-fuzz-data-user-test.dat >> ${EXECDIR}/results/mutational-fuzz-data-targeted-at-user-endpoint.log
    Run Keyword And Ignore Error    Run    echo " " >> ${EXECDIR}/results/mutational-fuzz-data-targeted-at-user-endpoint.log

send_post_request_to_order_endpoint_with_fuzzed_data
    Run Keyword And Ignore Error    Run    echo '{"id": 9, "petId": 9, "quantity": 1, "shipDate": "2021-07-29T00:00:00.000Z", "status": "placed", "complete": true}' | radamsa > ${EXECDIR}/resources/mutational-fuzz-data-order-test.dat
    Run Keyword And Ignore Error    Run    httpstat -o ${EXECDIR}/resources/httpstat-response-mutational-fuzz-data-order-output.json -X POST -H 'Content-Type: application/json' -d @${EXECDIR}/resources/mutational-fuzz-data-order-test.dat http://0.0.0.0:8080/store/order
    Run Keyword And Ignore Error    Run    TIMESTAMP=$(date); echo "======== :: Fuzz Test Data Tracker for mutational-fuzz-data-order-test.dat -- Logged this on.... $TIMESTAMP :: ========" >> ${EXECDIR}/results/mutational-fuzz-data-targeted-at-order-endpoint.log
    Run Keyword And Ignore Error    Run    echo " " >> ${EXECDIR}/results/mutational-fuzz-data-targeted-at-order-endpoint.log
    Run Keyword And Ignore Error    Run    cat ${EXECDIR}/resources/mutational-fuzz-data-order-test.dat >> ${EXECDIR}/results/mutational-fuzz-data-targeted-at-order-endpoint.log
    Run Keyword And Ignore Error    Run    echo " " >> ${EXECDIR}/results/mutational-fuzz-data-targeted-at-order-endpoint.log