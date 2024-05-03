#!/bin/bash

TIMESTAMP=$(date)
clear

if [ "$1" == "Stop-Containers-And-Build-Docker-Container-With-Compose" ]; then
  echo
  echo "------------------------------------[[[[ Stop-Containers-And-Build-Docker-Container-With-Compose ]]]]------------------------------------"
  echo
  echo "This will build the Docker image defined in the docker-compose.yml file. This run started on $TIMESTAMP."
  echo
  echo "Use this command to get Docker container IP addresses..."
  echo "docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}} name-of-the-docker-container"
  echo
  echo "If you start running out of disk space, consider running this docker command. WARNING: Only use this command if you understand the risk..."
  echo "docker system prune -a"
  echo
  rm -rf ./resources/api-application.log
  rm -rf ./resources/go-test-output.json
  rm -rf ./resources/httpstat-*
  rm -rf ./resources/toxiproxy.log
  rm -rf ./resources/*test.dat
  rm -rf ./resources/GraphwalkerPath.csv
  rm -rf ./resources/__pycache__
  rm -rf ./results/*.*
  rm -rf ./1
  rm -rf ./*.bin
  docker stop $(docker ps -a -q) &&
  docker rm $(docker ps -a -q)
  docker compose -f docker-compose.yml down
  docker compose -f docker-compose.yml rm -f
  docker compose -f docker-compose.yml build
  TIMESTAMP2=$(date)
  echo "This build ended on $TIMESTAMP2."
fi

if [ "$1" == "Run-Specific-Tests-Inside-Docker" ]; then
  echo
  echo "------------------------------------[[[[ Run-Specific-Tests-Inside-Docker ]]]]------------------------------------"
  echo
  echo "This Run-Specific-Tests-Inside-Docker script is running. This run started on $TIMESTAMP."
  echo
  echo
  docker-compose -f docker-compose.yml down
  docker-compose -f docker-compose.yml rm -f
  docker-compose -f docker-compose.yml build
  docker-compose run docker-test-runner run-go-rpa-tests.sh "$2"
  ## Un-comment the line below to manually explore or debug any tests in the Go Language files or the API mock/proxy tools. Please comment out the line above if you need to only run the tesing and debugging script below.
  #docker-compose run docker-test-runner run-go-rpa-tests.sh Manual-Scripted-Tests-In-Docker
  docker stop $(docker ps -a -q) &&
  docker rm $(docker ps -a -q)
  docker compose -f docker-compose.yml down
  docker compose -f docker-compose.yml rm -f
  TIMESTAMP2=$(date)
  echo "This test run ended on $TIMESTAMP2."
fi

if [ "$1" == "Start-Chaos-Proxy-Model-Based-Tests" ]; then
  echo
  echo "------------------------------------[[[[ Start-Chaos-Proxy-Model-Based-Tests ]]]]------------------------------------"
  echo
  echo "This Start-Chaos-Proxy-Model-Based-Tests script is running inside a Docker container. This run started on $TIMESTAMP."
  echo
  cd /tests
  robot --include Tests_Setup --listener ./resources/TimeTrackingListener.py --listener ./resources/DurationTrackingListener.py --report NONE --log test-setup-log.html --output test-setup-output.xml -d ./results ./generic-automation.robot 
  sleep 3
  ls -la
  go version
  go get 
  sleep 3
  robot --include Model-Based_Tests --listener ./resources/TimeTrackingListener.py --listener ./resources/DurationTrackingListener.py --report NONE --log chaos-proxy-model-based-tests-log.html --output chaos-proxy-model-based-tests-output.xml -d ./results ./generic-automation.robot 
  rm -rf ./*.bin
  TIMESTAMP2=$(date)
  echo "This test run ended on $TIMESTAMP2."
fi

if [ "$1" == "Start-Chaos-Proxy-Load-Tests" ]; then
  echo
  echo "------------------------------------[[[[ Start-Chaos-Proxy-Load-Tests ]]]]------------------------------------"
  echo
  echo "This Start-Chaos-Proxy-Load-Tests script is running inside a Docker container. This run started on $TIMESTAMP."
  echo
  rm -rf ./*.bin
  cd /tests
  robot --include Tests_Setup --listener ./resources/TimeTrackingListener.py --listener ./resources/DurationTrackingListener.py --report NONE --log test-setup-log.html --output test-setup-output.xml -d ./results ./generic-automation.robot 
  sleep 3
  ls -la
  go version
  go get 
  sleep 3
  robot --include Load_Tests --listener ./resources/TimeTrackingListener.py --listener ./resources/DurationTrackingListener.py --report NONE --log chaos-proxy-load-tests-log.html --output chaos-proxy-load-tests-output.xml -d ./results ./generic-automation.robot 
  rm -rf ./*.bin
  TIMESTAMP2=$(date)
  echo "This test run ended on $TIMESTAMP2."
fi

if [ "$1" == "Start-Go-Language-Functional-Tests" ]; then
  echo
  echo "------------------------------------[[[[ Start-Go-Language-Functional-Tests ]]]]------------------------------------"
  echo
  echo "This Start-Go-Language-Functional-Tests script is running inside a Docker container. This run started on $TIMESTAMP."
  echo
  rm -rf ./resources/go-test-output.json
  rm -rf ./resources/go-test-console-results.log
  cd /tests
  robot --include Tests_Setup --listener ./resources/TimeTrackingListener.py --listener ./resources/DurationTrackingListener.py --report NONE --log test-setup-log.html --output test-setup-output.xml -d ./results ./generic-automation.robot
  sleep 3
  ls -la
  go version
  go get 
  go test -v -json functional-tests_test.go > /tests/resources/go-test-output.json
  sleep 3
  cat ./resources/go-test-output.json | jq | grep ": Test" > /tests/resources/go-test-console-results.log
  cat /tests/resources/go-test-console-results.log
  cp /tests/resources/go-test-console-results.log /tests/results/go-test-console-results.log
  TIMESTAMP2=$(date)
  echo "This test run ended on $TIMESTAMP2."
fi

if [ "$1" == "Analyze-Functional-Tests-Generate-HTML-Logs" ]; then
  echo
  echo "------------------------------------[[[[ Analyze-Functional-Tests-Generate-HTML-Logs ]]]]------------------------------------"
  echo
  echo "This Analyze-Functional-Tests-Generate-HTML-Logs script is running inside a Docker container. This run started on $TIMESTAMP."
  echo
  cd /tests
  ls -la
  robot --include Functional_Tests_Analysis --listener ./resources/TimeTrackingListener.py --listener ./resources/DurationTrackingListener.py --report NONE --log go-test-api-functional-test-log.html --output go-test-api-functional-test-output.xml -d ./results ./generic-automation.robot
  TIMESTAMP2=$(date)
  echo "This test run ended on $TIMESTAMP2."
fi

if [ "$1" == "Start-All-Tests" ]; then
  echo
  echo "------------------------------------[[[[ Start-All-Tests ]]]]------------------------------------"
  echo
  echo "This Start-All-Tests script is running inside a Docker container. This run started on $TIMESTAMP."
  echo
  rm -rf ./*.bin
  cd /tests
  robot --include Tests_Setup --listener ./resources/TimeTrackingListener.py --listener ./resources/DurationTrackingListener.py --report NONE --log test-setup-log.html --output test-setup-output.xml -d ./results ./generic-automation.robot 
  sleep 3
  ls -la
  go version
  go get 
  sleep 3
  robot --include Run_All_Tests --listener ./resources/TimeTrackingListener.py --listener ./resources/DurationTrackingListener.py --report NONE --log combined-test-results-log.html --output combined-test-results-output.xml -d ./results ./generic-automation.robot 
  rm -rf ./*.bin
  TIMESTAMP2=$(date)
  echo "This test run ended on $TIMESTAMP2."
fi

if [ "$1" == "Manual-Scripted-Tests-In-Docker" ]; then
  echo
  echo "------------------------------------[[[[ Manual-Scripted-Tests-In-Docker ]]]]------------------------------------"
  echo
  echo "This Manual-Scripted-Tests-In-Docker script is running inside a Docker container. This run started on $TIMESTAMP."
  echo
  rm -rf /tests/resources/api-application.log
  curl -L https://raw.githack.com/stoplightio/prism/master/install | sh
  prism -h
  nohup prism mock -h 0.0.0.0 /tests/petstore.oas3.yaml > /tests/resources/api-application.log &
  sleep 3
  toxiproxy-server > /tests/resources/api-application.log 2>1 &
  toxiproxy-cli create exploratory-testing-proxy -l 127.0.0.1:8080 -u 0.0.0.0:4010 >> /tests/resources/toxiproxy.log 2>1 &
  toxiproxy-cli toxic add -t bandwidth -a rate=100 exploratory-testing-proxy  >> /tests/resources/toxiproxy.log 2>1 &
  # toxiproxy-cli toxic add -t slow_close -a delay=1000 exploratory-testing-proxy >> /tests/resources/toxiproxy.log 2>1 &
  # toxiproxy-cli toxic add -t reset_peer -a timeout=1000000 exploratory-testing-proxy  >> /tests/resources/toxiproxy.log 2>1 &
  sleep 3
  cd /tests
  ls -la
  echo '{"id": 1, "username": "user1", "firstName": "John", "lastName": "Doe", "email": "john.doe@example.com", "password": "123456", "phone": "1234567890", "userStatus": 1}' | radamsa > /tests/resources/radamsa-exploratory-fuzz-test.dat
  go version
  go get
  go run httpstat-test-runner.go -url http://0.0.0.0:4010/user/vitae -method GET
  # go run httpstat-test-runner.go -url http://0.0.0.0:4010/store/order -method POST -body '{"id": 10, "petId": 1, "quantity": 1, "shipDate": "2023-01-01T23:59:59.999Z", "status": "placed", "complete": true}' > /tests/resources/httpstat-exploratory-test-output.log
  # go run vegeta-load-test-runner.go -url http://0.0.0.0:8080/user/vitae
  # curl http://0.0.0.0:4010/user/!@#$
  # curl http://0.0.0.0:4010/user/vitae
  # curl -vv -X GET http://0.0.0.0:4010/no_auth/pets/findByStatus?status=available
  # curl -vv -X GET http://0.0.0.0:4010/pets
  # curl -vv -X GET http://0.0.0.0:4010/store/order/9 
  # httpstat -o ./resources/httpstat-response-output.json http://0.0.0.0:8080/user/vitae
  # httpstat -o ./resources/httpstat-temporary-response-body-output.log http://0.0.0.0:4010/user/vitae
  # httpstat -o ./resources/httpstat-temporary-response-body-output.log -X POST -H "Content-Type: application/json" -d @resources/test-data2.json http://0.0.0.0:4010/user
  # httpstat -o ./resources/httpstat-response-output.json -X POST -H Content-Type: application/json -d @resources/test-data1.json http://0.0.0.0:4010/store/order
  # httpstat -o ./resources/httpstat-response-output.json -X POST -H 'Content-Type: application/json' -d @resources/test-data2.json http://0.0.0.0:4010/user
  # httpstat -o ./resources/httpstat-response-output.json http://0.0.0.0:4010/user/vitae
  TIMESTAMP2=$(date)
  echo "This test run ended on $TIMESTAMP2."
fi

usage_explanation() {
  echo
  echo
  echo "------------------------------------[[[[ Tool Runner Script ]]]]------------------------------------"
  echo
  echo
  echo "This tool runner script REQUIRES BOTH DOCKER AND DOCKER-COMPOSE to be installed on your machine, and can be used to run the following commands."
  echo
  echo "You can view just this help menu again (without triggering any automation) by running 'bash ./run-go-rpa-tests.sh -h' or 'bash ./run-go-rpa-tests.sh --help'."
  echo
  echo "Installation instructions for Docker can be found here... https://docs.docker.com/"
  echo
  echo "bash ./run-go-rpa-tests.sh Stop-Containers-And-Build-Docker-Container-With-Compose"
  echo "bash ./run-go-rpa-tests.sh Run-Specific-Tests-Inside-Docker Start-Go-Language-Functional-Tests"
  echo "bash ./run-go-rpa-tests.sh Run-Specific-Tests-Inside-Docker Start-Chaos-Proxy-Model-Based-Tests"
  echo "bash ./run-go-rpa-tests.sh Run-Specific-Tests-Inside-Docker Start-Chaos-Proxy-Load-Tests"
  echo "bash ./run-go-rpa-tests.sh Run-Specific-Tests-Inside-Docker Analyze-Functional-Tests-Generate-HTML-Logs"
  echo "bash ./run-go-rpa-tests.sh Run-Specific-Tests-Inside-Docker Start-All-Tests"
  echo "bash ./run-go-rpa-tests.sh Run-Specific-Tests-Inside-Docker Manual-Scripted-Tests-In-Docker"
  echo
  echo
}

error_handler() {
  local error_message="$@"
  echo "${error_message}" 1>&2;
}

argument="$1"
if [[ -z $argument ]] ; then
  usage_explanation
else
  case $argument in
    -h|--help)
      usage_explanation
      ;;
    *)
      usage_explanation
      ;;
  esac
fi
