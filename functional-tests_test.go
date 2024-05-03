package main

import (
    "bytes"
    "fmt"
    "io/ioutil"
    "os/exec"
    "strings"
    "testing"
)

const baseURL = "http://0.0.0.0:4010"

type testCase struct {
    method          string // The HTTP method to use for the request.
    endpoint        string // The API endpoint to test.
    payloadFile     string // JSON request payloads are stored in files (example: test-data1.json) in the resources directory.
    expectedStatus  int // This is the expected HTTP status code.
    expectedBody    string // This is a string that is contained in the response body.
    applicationLogs string // This is a string that is contained in the API application logs.
}

// Executes the httpstat tool and writes the output to a httpstat-response-output.json file, 
// returns the command output and any errors encountered.
func executeHttpstat(t *testing.T, method, url, payloadFile string) (string, error) {
    outputFile := "./resources/httpstat-response-output.json"
    args := []string{"-o", outputFile, "-X", method, "-H", "Content-Type: application/json", url}
    if payloadFile != "" {
        payloadArgs := fmt.Sprintf("@%s", payloadFile)
        args = append(args[:len(args)-1], "-d", payloadArgs, args[len(args)-1])
        fmt.Printf("args: %s\n", args)
    }

    cmd := exec.Command("httpstat", args...)
    var out bytes.Buffer
    var stderr bytes.Buffer
    cmd.Stdout = &out
    cmd.Stderr = &stderr

    err := cmd.Run()
    if err != nil {
        return out.String(), fmt.Errorf("httpstat failed to run: %v, stderr: %s", err, stderr.String())
    }
    fmt.Printf("cmd: %s %v\n", cmd.Path, cmd.Args)
    return out.String(), nil
}

 // Reads and returns the contents of the httpstat-response-output.json file.
func readHttpstatFile(t *testing.T, filePath string) (string, error) {
    data, err := ioutil.ReadFile(filePath)
    if err != nil {
        return "", fmt.Errorf("failed to read output file: %v", err)
    }
    return string(data), nil
}

 // Reads and returns the contents of the api-application.log file.
func readMockAPILog(t *testing.T, filePath string) (string, error) {
    data, err := ioutil.ReadFile(filePath)
    if err != nil {
        return "", fmt.Errorf("failed to read Mock API log file: %v", err)
    }
    return string(data), nil
}

// The test data for the test checks are set here.
func TestHTTPRequests(t *testing.T) {
    testCases := []testCase{
        {"GET", baseURL + "/user/vitae", "", 200, "username", "[HTTP SERVER] get /user/vitae"},
        {"GET", baseURL + "/no_auth/pets/findByStatus?status=available", "", 200, "category", "[HTTP SERVER] get /no_auth/pets/findByStatus"},
        {"GET", baseURL + "/store/order/9", "", 200, "status", "[HTTP SERVER] get /store/order/9"},
        {"POST", baseURL + "/store/order", "resources/test-data1.json", 200, "petId", "[HTTP SERVER] post /store/order"},
        {"POST", baseURL + "/user", "resources/test-data2.json", 200, "", "[HTTP SERVER] post /user"}, 
    }

    // The actual test checks are triggered from here.
    for _, tc := range testCases {
        t.Run(fmt.Sprintf("%s %s", tc.method, tc.endpoint), func(t *testing.T) {
            httpstatResult, err := executeHttpstat(t, tc.method, tc.endpoint, tc.payloadFile)
            if err != nil {
                t.Fatal(err)
            }

            // Read the response output from the httpstat-response-output.json file.
            httpstatOutput, err := readHttpstatFile(t, "./resources/httpstat-response-output.json")
            if err != nil {
                t.Fatal(err)
            }

            // Read the Prism Mock Server api-application.log file.
            prismOutput, err := readMockAPILog(t, "./resources/api-application.log")
            if err != nil {
                t.Fatal(err)
            }

            // Check for expected status code in the httpstat command output.
            expectedStatusCode := fmt.Sprintf("HTTP/1.1 %d", tc.expectedStatus)
            if !strings.Contains(httpstatResult, expectedStatusCode) {
                t.Errorf("Expected status code %d not found in output", tc.expectedStatus)
            }

            // Check if the expected string is in the response recorded in the httpstat-response-output.json file.
            if tc.expectedBody != "" && !strings.Contains(httpstatOutput, tc.expectedBody) {
                t.Errorf("Expected body to contain %s, got %s", tc.expectedBody, httpstatOutput)
            }

             // Check if the expected string is in the Prism Mock Server api-application.log file.
            if tc.applicationLogs != "" && !strings.Contains(prismOutput, tc.applicationLogs) {
                t.Errorf("Expected Prism Mock API log file to contain %s, got %s", tc.applicationLogs, prismOutput)
            }
        })
    }
}

