package main

import (
"encoding/json"
"fmt"
"io"
"net/http"
"os"
)

type Server struct {
IP string `json:"ip"`
CN string `json:"cn"`
}

type Servers struct {
OVPNUDP []Server `json:"ovpnudp"`
WG      []Server `json:"wg"`
}

type Region struct {
ID      string  `json:"id"`
Name    string  `json:"name"`
Servers Servers `json:"servers"`
}

type ServerList struct {
Regions []Region `json:"regions"`
}

func main() {
url := "https://serverlist.piaservers.net/vpninfo/servers/v6"

// Fetch JSON
resp, err := http.Get(url)
if err != nil {
fmt.Println("Error fetching JSON:", err)
os.Exit(1)
}
defer resp.Body.Close()

if resp.StatusCode != 200 {
fmt.Printf("Server returned status %d\n", resp.StatusCode)
os.Exit(1)
}

// Read the entire body
body, err := io.ReadAll(resp.Body)
if err != nil {
fmt.Println("Error reading response:", err)
os.Exit(1)
}

// The server sometimes includes a signature line after the JSON
// Split by newline and take only the first line
lines := splitLines(string(body))
if len(lines) == 0 {
fmt.Println("No JSON found in response")
os.Exit(1)
}
jsonData := []byte(lines[0])

var sl ServerList
if err := json.Unmarshal(jsonData, &sl); err != nil {
fmt.Println("Error parsing JSON:", err)
os.Exit(1)
}

// Filter only CA Ontario
for _, region := range sl.Regions {
if region.ID == "ca_ontario" {
fmt.Println("Region:", region.Name)
fmt.Println("WireGuard servers:")
fmt.Println("------------------")
for _, s := range region.Servers.WG {
fmt.Printf("%s -> %s\n", s.CN, s.IP)
}
return
}
}

fmt.Println("CA Ontario region not found.")
}

// splitLines handles both \n and \r\n
func splitLines(s string) []string {
var lines []string
start := 0
for i := 0; i < len(s); i++ {
if s[i] == '\n' {
line := s[start:i]
if len(line) > 0 && line[len(line)-1] == '\r' {
line = line[:len(line)-1]
}
lines = append(lines, line)
start = i + 1
}
}
// Add last line if missing newline
if start < len(s) {
lines = append(lines, s[start:])
}
return lines
}
