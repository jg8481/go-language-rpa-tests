# go-language-rpa-tests

![Robot-Gopher](./image1.png)

## Go Language test tools enhanced with RPA

“All testers do exploratory testing. Some do it more deliberately and in intentionally skilled ways.” - Cem Kaner

`Go Language` by itself is a powerful and high-performance language built for scalability. It has many libraries that can be used to create automation, but there are some exploratory test strategies that can be more easily implemented (with less lines of code) using a `generic RPA framework` to complement the strengths of Go. For example, the following strategies are not easy to quickly create within a day or two using only pure Go Language code.
- [Model-Based Tests using Graphwalker's visual .graphml files](https://graphwalker.github.io/), combined with Chaos Tests
- Load Tests combined with Chaos Tests 
- Mutational Fuzz Tests combined with Model-Based Tests 
- Slack bots that report failures on all of the above
- Listener Interface that monitors every test and performs actions during runtime

This repository is a `collection of Go Language test tools` and strategies `enhanced with Robot Framework`, an open source RPA (Robotic Process Automation) and generic automation framework. The goal is to demonstrate how these two sides can work together to form a more powerful test strategy than just one side by itself. Here is a list of the Go Language tools and components that are being utilized. The examples utilizing these components and tools can also be used without RPA for hands-on exploratory testing.
- `go test`, the built-in Go Language test tool
- `httpstat` and `go-httpstat`, a Go Language tool and library (similar to `curl`) that gathers various metrics of HTTP requests 
- `vegeta`, a versatile and customizable HTTP load testing tool and library
- `toxiproxy`, a TCP Chaos Proxy tool

## Quick Walkthrough

All of the examples in this repository are designed to run within a Docker container. It is the only requirement to run everything explained below in this walkthrough section. The following documentation can be used to install Docker.
- https://docs.docker.com/get-docker/


### [Test Target + Setup] Prism + Toxiproxy

All of the tests will be targeting a `prism` mock API server through a TCP Chaos Proxy called `toxiproxy`. The `generic-automation.robot` file (combined with the `ToxiproxyChaosTestLibrary.py` and `PrismMockServerLibrary.py` RPA automation libraries) manages the setup and teardown of these tools. The documentation links below provide more details.
- https://github.com/stoplightio/prism/tree/master/docs/getting-started
- https://github.com/Shopify/toxiproxy?tab=readme-ov-file#usage

### [Functional Tests] Go Test + HTTPStat

The Functional Tests are handled by the `functional-tests_test.go` and `httpstat-test-runner.go` files. For MacOS and Linux users, you can run these tests with the following command from a terminal.
- `bash ./run-go-rpa-tests.sh Run-Specific-Tests-Inside-Docker Start-Go-Language-Functional-Tests`

Windows users can run the following command.
- `docker-compose run docker-test-runner run-go-rpa-tests.sh Start-Go-Language-Functional-Tests`

The results of the `go test` runner is set to provide JSON output. The following script can analyze the JSON results and generate clearer results in an HTML log file.
- `bash ./run-go-rpa-tests.sh Run-Specific-Tests-Inside-Docker Analyze-Functional-Tests-Generate-HTML-Logs`

Optionally, the `httpstat-test-runner.go` file can be used for hands-on exploratory testing using the following commands. 
- (MacOS/Linux users) `bash ./run-go-rpa-tests.sh Run-Specific-Tests-Inside-Docker Manual-Tests-Inside-Docker`
- (Windows users) `docker-compose run docker-test-runner run-go-rpa-tests.sh Manual-Tests-Inside-Docker`

### [Load Tests] Vegeta 

The Load Tests are handled by the `vegeta-load-test-runner.go` and `VegetaLoadTestLibrary.py` files. The script below runs two types of Load Tests, (1) a ramp-up load test runner and (2) a cusomizable load test runner. All of the Load Tests go through `toxiproxy` first reaching the `prism` mock server.
- `bash ./run-go-rpa-tests.sh Run-Specific-Tests-Inside-Docker Start-Chaos-Proxy-Load-Tests`

Windows users can run the following command.
- `docker-compose run docker-test-runner run-go-rpa-tests.sh Start-Chaos-Proxy-Load-Tests`

### [Model-based Tests] Graphwalker + Radamsa

The Model-based Tests are handled by the `generic-automation.robot` and `GraphwalkerModel.graphml` files. In addition to the `toxiproxy` Chaos Proxy automation mentioned above, the Graphwalker Model-based Tests displayed in the screenshot below use the `httpstat-test-runner.go` file and a Mutational Fuzzer called [Radamasa](https://gitlab.com/akihe/radamsa).

![Graphwalker](./image2.png)

For MacOS and Linux users, you can run these Model-based Tests with the following command from a terminal.
- `bash ./run-go-rpa-tests.sh Run-Specific-Tests-Inside-Docker Start-Graphwalker-Model-Based-Tests`

Windows users can run the following command.
- `docker-compose run docker-test-runner run-go-rpa-tests.sh Start-Graphwalker-Model-Based-Tests`

More information about Model-based Testing can be found in the links below.
- https://graphwalker.github.io/#articles
- https://www.harryrobinson.net/
- https://testoptimal.com/ref/starwest-2006-mbt-tutorial.pdf

### [RPA Bonus Features] Slack bot + Listener Interface

The Slack bot is a part of the `generic-automation.robot` file, and will send a Slack message using [slacktee](https://github.com/coursehero/slacktee) when any tests fail. The screenshots below demonstrate how a Model-based Test failure is sent to a specific Slack channel.

![Test Failure](./image3.png)

![Slack](./image4.png)

The `DurationTrackingListener.py` and `TimeTrackingListener.py` files use the Robot Framework Listener Interface to monitor the execution of all tests. Robot Framework's Listener Interface has many capapbilities, more details about it can be found in the links below.
- https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#listener-interface
- https://www.youtube.com/watch?v=lKu-9WKtYcg