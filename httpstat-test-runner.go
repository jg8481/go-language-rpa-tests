package main

import (
	"flag"
	"fmt"
	"io"
	"log"
	"net/http"
	"strings"
	"time"

	"github.com/tcnksm/go-httpstat"
)

// --[[ HTTPStat Test Runner - Go Language HTTPStat Test Library And Standalone Tool ]]--
//
// -->> Example Usage From Any Terminal <<--
//
// The following lines show how this simple customizable HTTP testing tool and library can be used. This tool is similar to curl, but with additional metrics.
//
// :: Customized Run ::
// A user or any generic automation framework can set parameters in the following way...
//
// go run httpstat-test-runner.go -url https://jsonplaceholder.typicode.com/posts -method POST -body '{"userId": 1}'
//
// :: Demonstration Run ::
// A user can run a quick demonstration with "urlParameter" defaulted to https://jsonplaceholder.typicode.com/posts...
// go run httpstat-test-runner.go

func main() {
	// These command-line flags collect parameters from a terminal (in Linux/Unix variant OS) or command-prompt (in Windows).
	// There are defaults set for each flag, for demonstration purposes.
	urlParameter := flag.String("url", "https://jsonplaceholder.typicode.com/posts", "URL to send the request to")
	methodParameter := flag.String("method", "GET", "HTTP method (GET, POST, etc.)")
	bodyParameter := flag.String("body", "", "JSON request body")
	flag.Parse()

	// Check the URL.
	if *urlParameter == "" {
		log.Fatal("Error: Please provide a valid URL using the -url flag")
	}

	var reqBody io.Reader
	if *bodyParameter != "" {
		reqBody = strings.NewReader(*bodyParameter)
	}

	// Create the HTTP request.
	req, err := http.NewRequest(*methodParameter, *urlParameter, reqBody)
	if err != nil {
		log.Fatal(err)
	}

	// The following is needed for JSON request payloads.
	req.Header.Set("Content-Type", "application/json")

	// Collect metrics using HTTPStat.
	var result httpstat.Result
	ctx := httpstat.WithHTTPStat(req.Context(), &result)
	req = req.WithContext(ctx)

	client := http.DefaultClient
	res, err := client.Do(req)
	if err != nil {
		log.Fatal(err)
	}
	// Ensure body is closed.
	defer res.Body.Close()

	result.End(time.Now())

	// Get the response body.
	body, err := io.ReadAll(res.Body)
	if err != nil {
		log.Fatal(err)
	}

	// Display the HTTPStat metrics, the status code, and the response body.
	fmt.Println("--------------")
	fmt.Printf("URL: %s\n", *urlParameter)
	fmt.Printf("Method: %s\n", *methodParameter)
	fmt.Printf("Status Code: %d\n", res.StatusCode)
	fmt.Println("--------------")
	fmt.Printf("Response Body:\n%s\n", body)
	fmt.Println("--------------")
	fmt.Printf("Metrics:\n%+v\n", result)
}
