package main

import (
	"encoding/base64"
	"flag"
	"fmt"
	"os"
	"time"

	vegeta "github.com/tsenart/vegeta/v12/lib"
)

// --[[ Vegeta Load Test Runner - Go Language Load Test Library And Standalone Tool ]]--
//
// -->> Example Usage From Any Terminal <<--
//
// The following lines show how this simple customizable load testing tool and library can be used.
//
// :: Customized Run ::
// A user or any generic automation framework can set parameters in the following way...
//
// go run vegeta-load-test-runner.go -rate 100 -duration 5s -url https://blazedemo.com/index.php -method GET
//
// echo -n '{"userId": 1}' | base64 # generates this base64 string... eyJ1c2VySWQiOiAxfQ==
// go run vegeta-load-test-runner.go -url https://jsonplaceholder.typicode.com/posts -body 'eyJ1c2VySWQiOiAxfQ==' -method POST
//
// :: Demonstration Run ::
// A user can run a quick demonstration with "urlParameter" defaulted to https://blazedemo.com/index.php...
// go run vegeta-load-test-runner.go

func main() {
	// These command-line flags collect parameters from a terminal (in Linux/Unix variant OS) or command-prompt (in Windows).
	// There are defaults set for each flag, for demonstration purposes.
	var (
		rateParameter     = flag.Int("rate", 100, "Requests per second")
		durationParameter = flag.Duration("duration", 5*time.Second, "Duration of the attack")
		urlParameter      = flag.String("url", "https://blazedemo.com/index.php", "Target URL")
		methodParameter   = flag.String("method", "GET", "HTTP Method")
		bodyParameter     = flag.String("body", "", "Request body as a base64 encoded string")
		outputParameter   = flag.String("output", "results.bin", "Output file for the results")
	)

	flag.Parse()

	// Create a new "Vegeta Attacker" which is required for the load test runner below.
	attacker := vegeta.NewAttacker()

	// Create a customized binary file to store results for further analysis.
	resultsFile, err := os.Create(*outputParameter)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error creating results file: %v\n", err)
		return
	}
	defer resultsFile.Close()
	encoder := vegeta.NewEncoder(resultsFile)

	var metrics vegeta.Metrics
	// The following will run the actual "Vegeta Attack" (basically the actual load test runner) process and feed the results to "Metrics".
	for results := range attacker.Attack(newTargeter(*urlParameter, *methodParameter, *bodyParameter), vegeta.Rate{Freq: *rateParameter, Per: time.Second}, *durationParameter, "Vegeta Load Test Runner - Now running the attacker") {
		metrics.Add(results)
		if err := encoder.Encode(results); err != nil {
			fmt.Fprintf(os.Stderr, "Error encoding result: %v\n", err)
			return
		}
	}
	metrics.Close()

	// The following two lines are another alternative "Vegeta Reporter" option. To use this you must un-comment these two lines, and erase or comment out all of the "fmt.Println" lines below.
	// reporter := vegeta.NewTextReporter(&metrics)
	// reporter.Report(os.Stdout)

	// Print the test results using customized console logs created through "Metrics".
	fmt.Println("")
	fmt.Println("")
	fmt.Println("Vegeta Load Test Runner - Results")
	fmt.Println("")
	fmt.Println("")
	fmt.Println("Requests:", metrics.Requests)
	fmt.Println("StatusCodes:", metrics.StatusCodes)
	fmt.Println("Errors", metrics.Errors)
	fmt.Println("Success Rate:", metrics.Success*100, "%")
	fmt.Println("Latencies (ms):")
	fmt.Println(" - Mean:", metrics.Latencies.Mean)
	fmt.Println(" - 50th percentile:", metrics.Latencies.P50)
	fmt.Println(" - 95th percentile:", metrics.Latencies.P95)
	fmt.Println(" - 99th percentile:", metrics.Latencies.P99)
	fmt.Println(" - Max:", metrics.Latencies.Max)
	fmt.Println("")
	fmt.Println("")
}

// This is the newTargeter helper function. It generates targets with dynamic or static content based on provided parameters given through the command-line flags above.
// You are probably thinking, "Why is this custom targeter expecting base64 strings?". This is because the Vegeta Lead Developer ("tsenart")
// is expecting a base64 string in the body parameter. The developer documented this requirement in the following link found in his README.md file...
// https://github.com/tsenart/vegeta?tab=readme-ov-file#json-format
func newTargeter(urlParameter, methodParameter, encodedBody string) vegeta.Targeter {
	return func(tgt *vegeta.Target) error {
		tgt.Method = methodParameter
		tgt.URL = urlParameter
		if encodedBody != "" {
			decodedBody, err := base64.StdEncoding.DecodeString(encodedBody)
			if err != nil {
				return fmt.Errorf("failed to decode body: %w", err)
			}
			tgt.Body = decodedBody
		}
		return nil
	}
}
