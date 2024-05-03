## Init

* Reopen in Development Container
* run `go mod init <package>`
* run `go mod tidy`
* try f.e. `go run ./ serve` or launch via _Launch Server_ run config, first launch might take some time

## Customize
* copy the docker-compose override example and customize it: `cp docker-compose.override.example.yml docker-compose.override.yml`
* add mod and sum: `git add go.mod go.sum`
